#!/usr/bin/env bash
#
#
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)

# install only on pi1
if [ "`hostname`" != "pi1.home"]; then
    exit 1
fi

echo "${magenta}Config global git user.name and user.email${reset}"
git config --global user.name "Stefanita Vilcu"
git config --global user.email "svilcu@gmail.com"
git config pull.rebase false

echo "${magenta}Installing Postgresql${reset}"
apt install -y postgresql libpq-dev postgresql-client postgresql-client-common

echo "${magenta}Installing espeak TTS engine${reset}"
apt install -y espeak espeak-data  libespeak-dev libespeak1

echo "${magenta}Installing packages required for coding${reset}"
apt install -y  minicom libtool libconfig-dev pylint spyder3 libgbm1 libxss1 libsecret-1-0 xpdf
if [ "`lsb_release -is`" = "Ubuntu" ]; then
    apt install -y firefox
else
    apt install -y firefox-esr
fi

echo "${magenta}Installing Python3 packages via apt${reset}"
apt install -y python3-pip python3-serial python3-serial-asyncio python3-espeak python3-kafka python3-psycopg2

echo "${magenta} Installing Python packages via pip${reset}"
pip3 install jira RPi

echo "${magenta} Installing zookeeper for Kafka${reset}"
apt install -y zookeeper zookeeperd default-jdk
systemctl enable zookeeper
systemctl start zookeeper

echo "${magenta} Installing Kafka${reset}"
wget https://mirror.efect.ro/apache/kafka/2.8.0/kafka_2.13-2.8.0.tgz -O /tmp/kafka_2.13-2.8.0.tgz
cd /usr/local/
tar zxvf /tmp/kafka_2.13-2.8.0.tgz
ln -s kafka_2.13-2.8.0 kafka
rm -f /tmp/kafka_2.13-2.8.0.tgz
cd -
cp templates/kafka.service /etc/systemd/system/

# by default Kafka comes with 1G of shared memory,
# we will use 256M since our traffic is small
sed -i 's|Xmx1G -Xms1G|Xmx256m -Xms256m|' /usr/local/kafka/bin/kafka-server-start.sh

systemctl daemon-reload
systemctl enable kafka.service
systemctl start kafka.service

echo "${magenta}Configuring Postgresql for Zabbix${reset}"
su -c "psql" - postgres <<EOF
ALTER USER postgres PASSWORD 'postgres';
\q
EOF
PGPASSWORD="postgres"
export PGPASSWORD
psql -U postgres -d postgres -h localhost -c "CREATE USER zabbix WITH PASSWORD 'zabbix';"
psql -U postgres -d postgres -h localhost -c "CREATE DATABASE zabbix;"
psql -U postgres -d postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE zabbix to zabbix;"

echo "${magenta}Installing Zabbix Server and snmp${reset}"
apt install -y zabbix-server-pgsql zabbix-frontend-php snmp

echo "${magenta}Populating the Zabbix Postgresql DB${reset}"
wget https://repo.zabbix.com/zabbix/5.0/ubuntu-arm64/pool/main/z/zabbix/zabbix_5.0.8.orig.tar.gz -O /tmp/zabbix_5.0.8.tar.gz
cd /tmp
tar zvxf zabbix_5.0.8.tar.gz
cat /tmp/zabbix-5.0.8/database/postgresql/schema.sql | sudo -u zabbix psql zabbix
cat /tmp/zabbix-5.0.8/database/postgresql/images.sql | sudo -u zabbix psql zabbix
cat /tmp/zabbix-5.0.8/database/postgresql/data.sql | sudo -u zabbix psql zabbix
rm -rf /tmp/zabbix*
rm -f /usr/share/zabbix/conf/zabbix.conf.php
cp /root/ava/templates/zabbix.conf.php /usr/share/zabbix/conf
sed -i 's|# DBPassword=|DBPassword=zabbix|g' /etc/zabbix/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent
systemctl enable zabbix-server zabbix-agent

echo "${magenta}Compiling libzbxpgsql, the Postgresql monitoring library for Zabbix${reset}"
cd /usr/src/
git clone https://github.com/zabbix/zabbix.git
cd /root/
git clone https://github.com/cavaliercoder/libzbxpgsql.git
cd libzbxpgsql
./autogen.sh
./configure
make
make install
mkdir -p /usr/lib/zabbix/modules
ln -s /usr/local/lib/libzbxpgsql.so /usr/lib/zabbix/modules/libzbxpgsql.so
cp /root/libzbxpgsql/conf/libzbxpgsql.conf /etc/zabbix/
sed -i 's|Xmx1G -Xms1G|Xmx256m -Xms256m|' /usr/local/kafka/bin/kafka-server-start.sh
rm -rf /usr/src/zabbix
rm -rf /root/libzbxpgsql

# if firefox and/or vscode complain about libgtk we need to:
# apt install --reinstall libgtk-3-0

update-alternatives --set iptables /usr/sbin/iptables-legacy

# add iptables rule for zabbix agent
iptables  -A INPUT -p tcp -m tcp --dport 10051 -j ACCEPT

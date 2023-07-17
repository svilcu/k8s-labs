#!/usr/bin/env bash
#
#title           :mkscript.sh
#description     :This script will make a header for a bash script.
#author		 :bgw
#date            :20111101
#version         :0.4
#usage		 :bash mkscript.sh
#notes           :Install Vim and Emacs to use this script.
#bash_version    :4.1.5(1)-release
#
#  Configures Ubuntu 21.04 or Debian 10 (Buster) with:
#    - hostname, IP and hosts file
#    - config.txt and cmdline.txt to support our modem and overclock the RPi to higher frequency
#    - updates the OS and in case of Debian 10, upgrades it to Debian 11
#    - install some essential packages.
#    - etc
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

# choice of: pi1, pi2, pi3, pi4
HOSTNAME="pi1"

declare -A host_ips
host_ips['pi1']='192.168.72.191'
host_ips['pi2']='192.168.72.192'
host_ips['pi3']='192.168.72.193'
host_ips['pi4']='192.168.72.194'

apt remove -y nano

# Update os
apt update
apt dist-upgrade -y
apt upgrade -y
apt-get autoremove -y
# some distros do not have lsb-release, wget, curl, git installed by default
apt install -y lsb-release wget curl git software-properties-common apt-transport-https zabbix-agent scdaemon

hostnamectl set-hostname ${HOSTNAME}.home

# Debian 10 (buster) has config files in /boot
# Ubuntu and Debian 11 has config files in /boot/firmware
if [ "`lsb_release -cs`" == "buster" ]; then
    BOOT_PREFIX="/boot"
else
    BOOT_PREFIX="/boot/firmware"
fi

echo "${magenta}Customizing ${BOOT_PREFIX}/cmdline.txt${reset}"
sed -i 's|console=serial0,115200 console=tty1||' ${BOOT_PREFIX}/cmdline.txt

echo "${magenta}Setting up parameters in ${BOOT_PREFIX}/config.txt${reset}"
sed -i 's|dtparam=audio=on|dtparam=audio=off|' ${BOOT_PREFIX}/config.txt
cat >> ${BOOT_PREFIX}/config.txt <<EOF
dtoverlay=disable-bt
dtoverlay=miniuart-bt
start_x=0
hdmi_enable_4kp60=0
gpu_mem=16
# overclocking to 2Ghz from the default 600Mhz
force_turbo=1
over_voltage=6
arm_freq=2000
#recommendation for the UART to work correctly.
#core_freq=250
EOF

echo "${magenta}Configuring serial speed in /usr/bin/btuart${reset}"
sed -i 's|bcm43xx 921600 noflow|bcm43xx 115200 noflow|g' /usr/bin/btuart

echo "${magenta}Configuring /etc/hosts${reset}"
cat >> /etc/hosts <<EOF
192.168.72.1    docsis.home docsis
192.168.72.197  nas.home nas
192.168.72.198  ilo-gen8.home ilo-gen8
192.168.72.199  catalyst.home catalyst
192.168.72.200  om.home om
192.168.72.201  minion.home minion
192.168.72.202  gen8.home gen8
192.268.72.240  ingress.sakura.k8s
# 192.168.72.240/28 used for Sakura Kubernetes Metal-LB
# Pi cluster
192.168.72.191  pi1.home  pi1
192.168.72.192  pi2.home  pi2
192.168.72.193  pi3.home  pi3
192.168.72.194  pi4.home  pi4
192.168.72.160  pi.home  pi
# 192.168.72.160/28 used for AVA Kubernetes Metal-LB
EOF

echo "${magenta}Enabling ssh Daemon and root login via ssh key${reset}"
echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
if [ `lsb_release -cs` == "buster" ]; then
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi
cat templates/id_rsa.pub >> /root/.ssh/authorized_keys
# just in case the host keys were not generated during install
ssh-keygen -A
systemctl enable ssh.service
systemctl restart ssh.service

echo "${magenta}Disabling Wi-Fi Daemon${reset}"
systemctl disable wpa_supplicant.service
systemctl mask wpa_supplicant.service
systemctl stop wpa_supplicant.service

echo "${magenta}Disabling Avahi Daemon${reset}"
systemctl disable avahi-daemon.socket avahi-daemon.service
systemctl mask avahi-daemon.socket avahi-daemon.service
systemctl stop avahi-daemon.socket avahi-daemon.service

echo "${magenta}Configuring static IP for eth0 and disabling DHCP${reset}"
if [ "`lsb_release -is`" = "Ubuntu" ]; then
    cp templates/99-disable-network-config.cfg /etc/cloud/cloud.cfg.d
    rm -f /etc/netplan/50-cloud-init.yaml
    cp templates/01-netplan.yaml /etc/netplan/
    sed -i 's|192.168.72.190|${host_ips[${HOSTNAME}]}|g' /etc/netplan/01-netplan.yaml
    netplan generate
    netplan apply
elif [ "`lsb_release -cs`" = "bullseye" ]; then
    echo "auto eth0" > /etc/network/interfaces.d/eth0
    echo "iface eth0 inet static" >> /etc/network/interfaces.d/eth0
    echo "    address ${host_ips[${HOSTNAME}]}/24" >> /etc/network/interfaces.d/eth0
    echo "    gateway 192.168.72.1" >> /etc/network/interfaces.d/eth0
    echo "domain home" > /etc/resolv.conf
    echo "search home" >> /etc/resolv.conf
    echo "nameserver 192.168.72.1" >> /etc/resolv.conf
elif [ "`lsb_release -cs`" = "buster" ]; then
    cat >> /etc/dhcpcd.conf <<EOF
interface eth0
static ip_address=${host_ips[${HOSTNAME}]}/24
static routers=192.168.72.1
static domain_name_servers=192.168.72.1
nohook wpa_supplicant
EOF
fi

# pi2, pi3, pi4 is our kubernetes cluster
if [ "$HOSTNAME" != "pi1" ] ; then
    echo "${magenta}Install kubernetes requirements${reset}"
    cat >>/etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
    echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >>/etc/profile
    sed -i 's/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' ${BOOT_PREFIX}/cmdline.txt
    if [ "`lsb_release -is`" = "Debian" ] ; then
        apt install -y open-iscsi
    fi
    if [ "$HOSTNAME" = "pi2" ] ; then
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh
        rm -f get_helm.sh
    fi
    update-alternatives --set iptables /usr/sbin/iptables-legacy
fi

if [ "`lsb_release -cs`" = "buster" ] ; then
    echo "${magenta}Upgrading Debian 10 to Debian 11${reset}"
    sed -i 's/^deb/#deb/' /etc/apt/sources.list
    echo "deb https://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list
    echo "deb https://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
    echo "deb https://deb.debian.org/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list
    apt update
    apt dist-upgrade -y
    apt upgrade -y
    apt autoremove -y
fi

echo "${magenta}Shut down the modems on the RPi${reset}"
echo "echo 0 > /sys/class/leds/led1/brightness" >> /etc/rc.local
echo "echo 0 > /sys/class/leds/led1/brightness" >> /etc/rc.local
iptables -A INPUT -p tcp -m tcp --dport 10050 -j ACCEPT

echo "${magenta}Shut down the modems on the RPi${reset}"
git clone git@gitlab.com:Qrl/zabbix.git
cp zabbix/userparameter_rpi.conf /etc/zabbix/zabbix_agentd.d/
usermod -a -G video zabbix

echo "${magenta}Configure Zabbix Agent${reset}"
echo "PidFile=/var/run/zabbix/zabbix_agentd.pid" > /etc/zabbix/zabbix_agentd.conf
echo "LogFile=/var/log/zabbix-agent/zabbix_agentd.log" >> /etc/zabbix/zabbix_agentd.conf
echo "LogFileSize=0" >> /etc/zabbix/zabbix_agentd.conf
echo "Server=192.168.72.191" >> /etc/zabbix/zabbix_agentd.conf
echo "ServerActive=192.168.72.191" >> /etc/zabbix/zabbix_agentd.conf
echo "Hostname=${HOSTNAME}" >> /etc/zabbix/zabbix_agentd.conf
echo "Include=/etc/zabbix/zabbix_agentd.conf.d/" >> /etc/zabbix/zabbix_agentd.conf

# echo "${magenta}Update the RPi firmware and reboot${reset}"
# UPDATE_SELF=0 SKIP_WARNING=1 RPI_REBOOT=1 rpi-update

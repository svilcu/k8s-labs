# Configuration of the Banana PI BPI-R3 router

## Install OpenWRT on Banana PI R3 router

Use this [Forum Link](https://forum.banana-pi.org/t/bpi-r3-how-to-flash-openwrt-snapshot-on-emmc/14055/5) for installing the OS on the EMMC.
Since the time of writting this article, OpenWRT promoted the Banana Pi R3 into the Releases, and for that you can use the this image: [SD card image download link](https://downloads.openwrt.org/releases/23.05.0-rc2/targets/mediatek/filogic/openwrt-23.05.0-rc2-mediatek-filogic-bananapi_bpi-r3-sdcard.img.gz).

## Install and configure software

- bootstrap python on OpenWRT, required by our Ansible roles.
- install luci with the default uhttpd server
- install and configure powerDNS as a replacer for DNSmasq

opkg install kmod-nvme mmc-utils kmod-mtd-rw lsblk parted uvol autopart

opkg install luci-ssl  luci-app-statistics luci-app-upnp

opkg install openvpn-openssl openvpn-easy-rsa luci-app-openvpn

opkg install pdns pdns-tools pdns-recursor pdns-backend-sqlite3

opkg install prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-netstat prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations

opkg install collectd-mod-ethstat collectd-mod-ipstatistics collectd-mod-irq collectd-mod-load collectd-mod-ping collectd-mod-powerdns collectd-mod-sqm collectd-mod-thermal collectd-mod-wireless
/etc/init.d/collectd enable
[Statistics for PowerDNS](https://openwrt.org/docs/guide-user/luci/luci_app_statistics?s[]=powerdns)
[DHCP configuration](https://openwrt.org/docs/guide-user/base-system/dhcp_configuration)

## Upgrade to the latest snapshot

...
base-files busybox ca-bundle dnsmasq dropbear e2fsprogs f2fsck firewall4 fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-hwmon-pwmfan kmod-i2c-gpio kmod-leds-gpio kmod-mt7915e kmod-mt7986-firmware kmod-nft-offload kmod-sfp kmod-usb3 libc libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-wolfssl
...

- [Banana Pi BPI-R3 wiki page](https://wiki.banana-pi.org/Banana_Pi_BPI-R3)
- [Bootstrap Python on OpenWRT](https://github.com/johanneskastl/ansible-role-bootstrap_python_on_OpenWRT.git)

### yamllint disable rule:line-length

  If there are not exactly 1 partitions on the NVMe it will be partitioned to a single partition.

pdns_server --daemon=no --loglevel=9

### Create repositories

If we need to create DEB and RPM repositories we need to figure out how to instal "createrepo" and "dpkg-dev" on the OpenWRT

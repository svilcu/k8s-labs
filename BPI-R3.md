# Configuration of the Banana PI BPI-R3 router

## Install OpenWRT on Banana PI R3 router.

Use this [Forum Link]() for:


[SD card image download link](https://downloads.openwrt.org/releases/23.05.0-rc2/targets/mediatek/filogic/openwrt-23.05.0-rc2-mediatek-filogic-bananapi_bpi-r3-sdcard.img.gz)

```
# unzip the image
gzip -d openwrt-mediatek-filogic-bananapi_bpi-r3-sdcard.img.gz

# replace /dev/sdd with the corresponding device
dd if=openwrt-mediatek-filogic-bananapi_bpi-r3-sdcard.img of=/dev/sdd bs=1M
```

## Install the image on the internal memory devices

In order to complete this process you need the serial console from the BPI-R3 connected to the computer via the serial-to-USB adapter, I am using [this](https://www.amazon.de/gp/product/B01N9RZK6I/ref=ppx_yo_dt_b_asin_title_o06_s00?ie=UTF8&th=1).
Connect the terminal emulator (Minicom or Putty) to the COM port 115200 8N1 no flow control.

|Jumper Setting| A | B | C | D |
|---|---|---|---|---|
| SPIM-NOR|low|low|low| x |
|SPIM-NAND|low|low|low| x |
| eMMC | low | High | x | low |
| SD | High | High | x | High |

### Install image from SD on NAND

Set the jumpers to boot from SD card. All High.
Having the console connected, reset the device.
During boot, have a key pressed, the recommended is right arrow.
Select option 8. "Install bootloader, recovery and production to NAND.
Reboot

### Boot from NAND and install the image from SD card to eMMC

## Install and configure software

- bootstrap python on OpenWRT, required by our Ansible roles.
- install luci with the default uhttpd server
- install and configure powerDNS as a replacer for 

opkg update
opkg install kmod-nvme mmc-utils kmod-mtd-rw lsblk parted uvol autopart

opkg install luci-ssl  luci-app-statistics luci-app-upnp 

opkg install openvpn-openssl openvpn-easy-rsa luci-app-openvpn

opkg install pdns pdns-tools pdns-recursor pdns-backend-sqlite3

opkg install prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-netstat prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations

opkg install collectd-mod-ethstat collectd-mod-ipstatistics collectd-mod-irq collectd-mod-load collectd-mod-ping collectd-mod-powerdns collectd-mod-sqm collectd-mod-thermal collectd-mod-wireless
/etc/init.d/collectd enable
https://openwrt.org/docs/guide-user/luci/luci_app_statistics?s[]=powerdns
https://openwrt.org/docs/guide-user/base-system/dhcp_configuration


## Upgrade to the latest snapshot
```bash
    cd /tmp
    wget https://downloads.openwrt.org/releases/23.05.0-rc2/targets/mediatek/filogic/openwrt-23.05.0-rc2-mediatek-filogic-bananapi_bpi-r3-squashfs-sysupgrade.itb
    sysupgrade -v /tmp/openwrt-mediatek-filogic-bananapi_bpi-r3-squashfs-sysupgrade.itb
```
...
base-files busybox ca-bundle dnsmasq dropbear e2fsprogs f2fsck firewall4 fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-hwmon-pwmfan kmod-i2c-gpio kmod-leds-gpio kmod-mt7915e kmod-mt7986-firmware kmod-nft-offload kmod-sfp kmod-usb3 libc libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-wolfssl
...

* [bpi-r3-how-to-flash-openwrt](https://forum.banana-pi.org/t/bpi-r3-how-to-flash-openwrt-snapshot-on-emmc/14055/5)
* [Firmware download](https://firmware-selector.openwrt.org/?version=SNAPSHOT&target=mediatek%2Ffilogic&id=bananapi_bpi-r3)
* [How to burn image](https://wiki.banana-pi.org/Getting_Started_with_BPI-R3#How_to_burn_image_to_onboard_eMMC)
* [Bootstrap Python on OpenWRT](https://github.com/johanneskastl/ansible-role-bootstrap_python_on_OpenWRT.git)
https://github.com/imp1sh/ansible_openwrt

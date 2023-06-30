# Configuration of the Banana PI BPI-R3 router

## Downloading and burning the image on the SD card

[SD card image download link](https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/openwrt-mediatek-filogic-bananapi_bpi-r3-sdcard.img.gz)

```
# unzip the image
gzip -d openwrt-mediatek-filogic-bananapi_bpi-r3-sdcard.img.gz

# replace /dev/sdd with the corresponding device
dd if=openwrt-mediatek-filogic-bananapi_bpi-r3-sdcard.img of=/dev/sdd bs=1M
```

## Install the image on the internal memory devices

In order to complete this process you need the serial console from the BPI-R3 connected to the computer via the serial-to-USB adapter ordered with the box or with one like [this](https://www.amazon.de/gp/product/B01N9RZK6I/ref=ppx_yo_dt_b_asin_title_o06_s00?ie=UTF8&th=1).
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


opkg update
opkg install luci-ssl kmod-nvme mmc-utils kmod-mtd-rw lsblk parted uvol autopart

openvpn-openssl openvpn-easy-rsa
pdns pdns-tools pdns-recursor pdns-backend-sqlite3

prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-netstat prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations
...
base-files busybox ca-bundle dnsmasq dropbear e2fsprogs f2fsck firewall4 fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-hwmon-pwmfan kmod-i2c-gpio kmod-leds-gpio kmod-mt7915e kmod-mt7986-firmware kmod-nft-offload kmod-sfp kmod-usb3 libc libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-wolfssl
...

* [bpi-r3-how-to-flash-openwrt](https://forum.banana-pi.org/t/bpi-r3-how-to-flash-openwrt-snapshot-on-emmc/14055/5)
* [Firmware download](https://firmware-selector.openwrt.org/?version=SNAPSHOT&target=mediatek%2Ffilogic&id=bananapi_bpi-r3)
* [How to burn image](https://wiki.banana-pi.org/Getting_Started_with_BPI-R3#How_to_burn_image_to_onboard_eMMC)
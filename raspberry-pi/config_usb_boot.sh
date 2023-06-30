#!/usr/bin/env bash
#
# Configures a RPi 4B to boot from USB from command line
# https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md
#

apt update
apt install -y lshw

if [ $(lshw -short | grep -c BCM2711) -eq 1 ]; then
    echo -n "Configuring your" `cat /proc/device-tree/model`
    echo " to boot from USB"
    echo "Saving EEPROM config"
    rpi-eeprom-config -o boot.conf
    # set boot order then SD card(1), USB MSD first (4), then reload(f)
    sed -e 's|BOOT_ORDER=\*|BOOT_ORDER=0xf41|' boot.conf
    echo "Updating EEPROM config"
    rpi-eeprom-config -a boot.conf
    rm -f boot.conf
else
    echo "BCM2711 device not found"
fi

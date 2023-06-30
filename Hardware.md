# Hardware Specifications

Details of all the hardware used in the project

## Raspberry PI cluster

|Node name | Manufacturer | Model | Processor | Cores | Memory |
|----|----|----|----|----|----|
|rpi4b-[1 - 5] | Raspberry Pi| 4 Model B Rev 1.4| Broadcom BCM2711 | 4 x 1.8GHz Cortex-A72| 8GB LPDDR4-3200 |

## Alternatives cluster

|Node name | Manufacturer | Model | Processor | Cores | Memory |
|----|----|----|----|----|----|
| vim4-1 | Khadas | VIM4 | Amlogic A311D2 | 4 x 2.2GHz Cortex-A73 and 4x 2.0GHz Cortex-A53 | 8GB LPDDR4X-2016 |
| rock3a-1 | Radxa | Rock 3 Model A | rk3568 | 4 x 2.0GHz Cortex-A55 | 8GB LPDDR4-1560 |
| rock5b-1 | Radxa | Rock 5 Model B | rk3588 | 4 x 2.0GHz Cortex-A55 | 8GB LPDDR4-1560 |
| rock3a-1 | Radxa | Rock 3 Model A | rk3568 | 4 x 2.0GHz Cortex-A55 | 8GB LPDDR4-1560 |



## Remove the pi initial Wizard

```bash
apt install cloud-guest-utils
```

## Resize the partition

```bash
dd if=2023-02-21-raspios-bullseye-arm64-lite.img of=/dev/sda bs=1M
echo ", +" | sfdisk -N 2 /dev/sda || growpart /dev/sda 2 || parted /dev/sda resizepart 2 100%
partprobe /dev/sda
resize2fs /dev/sda2
e2fsck -fy /dev/sda2
```

In my script that makes customised images for me I delete /etc/systemd/system/multi-user.target.wants/userconfig.service to prevent that script running.

```bash
root@rpi-installer:~# cat /sys/class/net/eth0/address
```

dc:a6:32:f0:9b:ad

```bash
mount /dev/sda1 /mnt/sda1
touch /mnt/sda1/ssh
```

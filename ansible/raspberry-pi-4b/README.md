# Configs for Raspberry PI

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

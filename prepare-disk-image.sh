#!/bin/bash

img=test.img

dd if=/dev/zero of=$img bs=1MB count=512

device=`sudo losetup -f --show $img`

sudo gdisk $device <<EOF
n
1
2048
+64M
EF00
n
2


8300
w
Y
EOF
sudo partprobe

sudo mkfs.vfat ${device}p1
sudo mkfs.ext4 ${device}p2

sudo mkdir /opt/rootfs
sudo mount ${device}p2 /opt/rootfs
sudo mkdir -p /opt/rootfs/boot/efi
sudo mount ${device}p1 /opt/rootfs/boot/efi

#!/bin/bash

img=test.img
rootfs=/opt/rootfs

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
sudo losetup -d $device
device=`sudo losetup -f -P --show $img`

sudo mkfs.vfat -F 32 -n ESP ${device}p1
sudo mkfs.ext4 -L RootFS ${device}p2

echo Mounting ${device}p2 at ${rootfs}
sudo mkdir ${rootfs}
sudo mount ${device}p2 ${rootfs}
echo Mounting ${device}p1 at ${rootfs}/boot/efi
sudo mkdir -p ${rootfs}/boot/efi
sudo mount ${device}p1 ${rootfs}/boot/efi

# Run build step
sudo apt-get update && sudo apt-get install -y qemu-user-static debootstrap
sudo debootstrap --arch=arm64 jammy ${rootfs} http://ports.ubuntu.com/ubuntu-ports

# Config fstab
p1uuid=`lsblk --fs | awk '/ESP/ $5}'`
p2uuid=`lsblk --fs | awk '/RootFS/ {print $5}'`
echo UUID=$p1uuid
echo UUID=$p2uuid
sudo cat > ${rootfs}/etc/fstab <<EOF
UUID=$p2uuid / ext4 errors=remount-ro 0 1
UUID=$p1uuid=0077 0 1
EOF

echo Running thirdstage.sh inside chroot
sudo cp thirdstage.sh ${rootfs}
sudo chroot ${rootfs} /bin/bash /thirdstage.sh
sudo rm ${rootfs}/thirdstage.sh

echo Unmounting ${rootfs}/boot/efi
sudo umount ${rootfs}/boot/efi
echo Unmounting ${rootfs}
sudo umount ${rootfs}

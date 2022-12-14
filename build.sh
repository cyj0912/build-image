#!/bin/bash

img=flash.img
rootfs=/opt/rootfs

# Prepare image
dd if=/dev/zero of=$img bs=1048576 count=3072
device=`sudo losetup -f --show $img`

sudo gdisk $device <<EOF
n
1
32768
+128M
EF00
n
2



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

# D.3.4.2. Mount Partitions
p1uuid=`sudo blkid ${device}p1 -o export | grep ^UUID=`
p2uuid=`sudo blkid ${device}p2 -o export | grep ^UUID=`
echo ${device}p1 $p1uuid
echo ${device}p2 $p2uuid
sudo tee ${rootfs}/etc/fstab <<EOF
$p2uuid / ext4 errors=remount-ro 0 1
$p1uuid /boot/efi vfat defaults 0 1
EOF

sudo mount -t proc /proc ${rootfs}/proc
sudo mount -t sysfs /sys ${rootfs}/sys
sudo mount -o bind /dev ${rootfs}/dev
sudo mount -o bind /dev/pts ${rootfs}/dev/pts

echo Running thirdstage.sh inside chroot
sudo cp thirdstage.sh ${rootfs}
sudo chroot ${rootfs} /bin/bash /thirdstage.sh
sudo rm ${rootfs}/thirdstage.sh

echo Unmounting ${rootfs}
sudo umount --recursive ${rootfs}

# Write bootloader
wget https://beta.armbian.com/pool/main/l/linux-u-boot-rockpi-4c-edge/linux-u-boot-edge-rockpi-4c_22.08.1_arm64.deb
dpkg-deb -R linux-u-boot-edge-rockpi-4c_22.08.1_arm64.deb uboot
. uboot/usr/lib/u-boot/platform_install.sh
write_uboot_platform $PWD/uboot$DIR $device

# Wrap up image
sudo losetup -d ${device}
echo Compressing image...
tar -cf ${img}.tar.zstd -I"zstd -19 -T0" $img
echo Done!

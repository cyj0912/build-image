#!/bin/bash
echo Enter thirdstage

apt-get clean

# D.3.4.3. Setting Timezone
# dpkg-reconfigure tzdata

# D.3.4.4. Configure Networking
# echo DebianHostName > /etc/hostname

# D.3.4.5. Configure Apt

# D.3.4.6. Configure Locales and Keyboard
# apt-get install locales
# dpkg-reconfigure locales

# D.3.5. Install a Kernel
apt-get install linux-image-arm64

# D.3.6. Set up the Boot Loader
apt-get install grub-efi-arm64
grub-install --removable
update-grub

# D.3.7. Remote access: Installing SSH and setting up access
apt-get install ssh
adduser linux
echo root:password | chpasswd
echo linux:password | chpasswd

# D.3.8. Finishing touches
apt-get clean

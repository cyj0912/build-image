#!/bin/bash
echo Enter thirdstage

apt-get clean
apt-get update

# D.3.4.3. Setting Timezone
# dpkg-reconfigure tzdata

# D.3.4.4. Configure Networking
# echo DebianHostName > /etc/hostname

# D.3.4.5. Configure Apt

# D.3.4.6. Configure Locales and Keyboard
# apt-get install locales
# dpkg-reconfigure locales

# D.3.5. Install a Kernel
apt-get install -y linux-image-generic || exit 1

# D.3.6. Set up the Boot Loader
apt-get install -y grub-efi-arm64 || exit 1
# grub-install --removable || exit 1
# update-grub || exit 1

# D.3.7. Remote access: Installing SSH and setting up access
apt-get install -y ssh || exit 1
adduser linux
echo Setting default passwords
echo root:password | chpasswd
echo linux:password | chpasswd

# D.3.8. Finishing touches
apt-get clean

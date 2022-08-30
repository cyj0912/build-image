#!/bin/bash
echo Enter thirdstage

# D.3.4.3. Setting Timezone
# dpkg-reconfigure tzdata

# D.3.4.4. Configure Networking
echo build-image > /etc/hostname

# D.3.4.5. Configure Apt
dist_release=`cat /etc/apt/sources.list | awk '{print $3}'`
sed -e "h; p; s/${dist_release}/${dist_release}-security/; p; g; s/${dist_release}/${dist_release}-updates/" /etc/apt/sources.list | sed -e 's/main/main restricted universe multiverse/' | tee /tmp/sources.list
cp /tmp/sources.list /etc/apt/sources.list
rm /tmp/sources.list

apt-get update
apt-get upgrade
apt-get clean

# D.3.4.6. Configure Locales and Keyboard
# apt-get install locales
# dpkg-reconfigure locales

# D.3.5. Install a Kernel
apt-get install -y linux-image-generic || exit 1

# D.3.6. Set up the Boot Loader
apt-get install -y grub-efi-arm64 || exit 1
grub-install --removable || exit 1
update-grub || exit 1

# D.3.7. Remote access: Installing SSH and setting up access
apt-get install -y ssh || exit 1
useradd -m -s /bin/bash linux
echo Setting default passwords
echo root:password | chpasswd
echo linux:password | chpasswd

# D.3.8. Finishing touches
apt-get clean

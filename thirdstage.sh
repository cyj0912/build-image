#!/bin/bash
echo Enter thirdstage

# D.3.4.3. Setting Timezone

# D.3.4.4. Configure Networking

# D.3.4.5. Configure Apt

# D.3.4.6. Configure Locales and Keyboard

# D.3.5. Install a Kernel

# D.3.6. Set up the Boot Loader

# D.3.7. Remote access: Installing SSH and setting up access
apt install ssh
passwd <<< password
adduser linux
passwd linux <<< password

# D.3.8. Finishing touches
apt clean

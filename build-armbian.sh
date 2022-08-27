#!/bin/sh

git clone https://github.com/armbian/build.git
cd build

sudo ./compile.sh BOARD=rockpi-4b BRANCH=current BUILD_MINIMAL=no BUILD_DESKTOP=no KERNEL_ONLY=yes KERNEL_CONFIGURE=no

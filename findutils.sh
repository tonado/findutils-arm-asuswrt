#!/bin/bash
#############################################################################
# Findutils for AsusWRT
#
# This script downloads and compiles all packages needed for adding 
# the GNU find, locate and xargs functions to Asus ARM routers.
#
# Before running this script, you must first compile your router firmware so
# that it generates the AsusWRT libraries.  Do not "make clean" as this will
# remove the libraries needed by this script.
#############################################################################
PATH_CMD="$(readlink -f $0)"

set -e
set -x

#REBUILD_ALL=0
PACKAGE_ROOT="$HOME/asuswrt-merlin-addon/asuswrt"
SRC="$PACKAGE_ROOT/src"
ASUSWRT_MERLIN="$HOME/asuswrt-merlin"
TOP="$ASUSWRT_MERLIN/release/src/router"
BRCMARM_TOOLCHAIN="$ASUSWRT_MERLIN/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3"
SYSROOT="$BRCMARM_TOOLCHAIN/arm-brcm-linux-uclibcgnueabi/sysroot"
echo $PATH | grep -qF /opt/brcm-arm || export PATH=$PATH:/opt/brcm-arm/bin:/opt/brcm-arm/arm-brcm-linux-uclibcgnueabi/bin:/opt/brcm/hndtools-mipsel-linux/bin:/opt/brcm/hndtools-mipsel-uclibc/bin
[ ! -d /opt ] && sudo mkdir -p /opt
[ ! -h /opt/brcm ] && sudo ln -sf $HOME/asuswrt-merlin/tools/brcm /opt/brcm
[ ! -h /opt/brcm-arm ] && sudo ln -sf $BRCMARM_TOOLCHAIN /opt/brcm-arm
[ ! -d /projects/hnd/tools/linux ] && sudo mkdir -p /projects/hnd/tools/linux
[ ! -h /projects/hnd/tools/linux/hndtools-arm-linux-2.6.36-uclibc-4.5.3 ] && sudo ln -sf /opt/brcm-arm /projects/hnd/tools/linux/hndtools-arm-linux-2.6.36-uclibc-4.5.3
#sudo apt-get install xutils-dev libltdl-dev automake1.11
#MAKE="make -j`nproc`"
MAKE="make -j1"

############# ###############################################################
# FINDUTILS # ###############################################################
############# ###############################################################

DL="findutils-4.6.0.tar.gz"
URL="https://ftp.gnu.org/pub/gnu/findutils/$DL"
mkdir -p $SRC/findutils && cd $SRC/findutils
FOLDER="${DL%.tar.gz*}"
[ "$REBUILD_ALL" == "1" ] && rm -rf "$FOLDER"
if [ ! -f "$FOLDER/__package_installed" ]; then
[ ! -f "$DL" ] && wget $URL
[ ! -d "$FOLDER" ] && tar xzvf $DL
cd "$FOLDER"

PKG_CONFIG_PATH="$PACKAGE_ROOT/lib/pkgconfig" \
SYSROOT="$HOME/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/arm-brcm-linux-uclibcgnueabi/sysroot" \
TOP="$HOME/asuswrt-merlin/release/src/router" \
OPTS="-ffunction-sections -fdata-sections -O3 -pipe -march=armv7-a -mtune=cortex-a9 -fno-caller-saves -mfloat-abi=soft -Wall -fPIC -std=gnu99 -I$PACKAGE_ROOT/include" \
CFLAGS="$OPTS" CPPFLAGS="$OPTS" \
LDFLAGS="-ffunction-sections -fdata-sections -Wl,--gc-sections -L$PACKAGE_ROOT/lib" \
./configure \
--host=arm-brcm-linux-uclibcgnueabi \
'--build=' \
--prefix=$PACKAGE_ROOT \
--enable-threads=posix \
--disable-silent-rules \
--disable-rpath

$MAKE
make install
touch __package_installed
fi


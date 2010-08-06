#!/bin/bash
KERNEL_DIR=/media/OVERO_BOOT
ROOTFS_DIR=/media/OVERO_ROOT
PREBUILT_VERSION=0.92
PREBUILT_TYPE=console

################################################################################
# DO NOT EDIT BELOW HERE
################################################################################
BASE_URL="http://www.gumstix.net/overo-gm-images/v${PREBUILT_VERSION}"

MLO="MLO-overo-v${PREBUILT_VERSION}"
ROOTFS="omap3-${PREBUILT_TYPE}-image-overo-v${PREBUILT_VERSION}.tar.bz2"
UBOOT="u-boot-overo-v${PREBUILT_VERSION}.bin"
KERNEL="uImage-overo-v${PREBUILT_VERSION}.bin"

MLO_URL="${BASE_URL}/${MLO}"
ROOTFS_URL="${BASE_URL}/${ROOTFS}"
UBOOT_URL="${BASE_URL}/${UBOOT}"
KERNEL_URL="${BASE_URL}/${KERNEL}"

Q=

echo "===== OVERO                       ====="

export `bitbake -e 2>/dev/null | grep "^DL_DIR=" | sed 's/"//g'`

if [ -z $DL_DIR ] ; then
    echo "ERROR: OE source download dir not found"
    exit 1
fi

if [ ! -d $KERNEL_DIR ] ; then
    echo "ERROR: Kernel partition not found ($KERNEL_DIR)"
    exit 1
fi

if [ ! -d $ROOTFS_DIR ] ; then
    echo "ERROR: Root file system partition not Found ($ROOTFS_DIR)"
    exit 1
fi

echo "Download gumstix prebuilt images v$PREBUILT_VERSION (Y/N)"

read -n 1 -s ky
if [ "$ky" == "Y" ] ; then
    echo "===== Downloading           ====="
    $Q wget -c -P $DL_DIR $MLO_URL $ROOTFS_URL $UBOOT_URL $KERNEL_URL
fi

echo "Clear existing FS on $ROOTFS_DIR (Y/N)"

read -n 1 -s ky
if [ "$ky" == "Y" ] ; then
    echo "===== DELETING sdcard/*           ====="
    $Q sudo rm -rf $ROOTFS_DIR/*
fi

echo "Extract rootfs to $ROOTFS_DIR (Y/N)"

read -n 1 -s ky
if [ "$ky" == "Y" ] ; then
    echo "===== EXTRACTING ROOT FILE SYSTEM ====="
    $Q sudo tar xvjf $DL_DIR/$ROOTFS -C $ROOTFS_DIR > /tmp/extract.log
fi

cp /tmp/extract.log .

echo "Copy MLO to $KERNEL_DIR (Y/N)"
read -n 1 -s mlo
if [ "$mlo" == "Y" ] ; then
    echo "===== COPYING MLO                 ====="
    $Q cp $DL_DIR/$MLO $KERNEL_DIR/MLO
fi

echo "Copy u-boot to $KERNEL_DIR (Y/N)"
read -n 1 -s ubt
if [ "$ubt" == "Y" ] ; then
    echo "===== COPYING U-BOOT              ====="
    $Q cp $DL_DIR/$UBOOT $KERNEL_DIR/u-boot.bin
fi

echo "Copy kernel to $KERNEL_DIR (Y/N)"
read -n 1 -s rfsy
if [ "$rfsy" == "Y" ] ; then
    echo "===== COPYING KERNEL              ====="
    $Q cp $DL_DIR/$KERNEL $KERNEL_DIR/uImage
fi

echo "===== UNMOUNTING ROOT FILE SYSTEM ====="
$Q sudo umount $ROOTFS_DIR
echo "===== UNMOUNTING KERNEL           ====="
$Q sudo umount $KERNEL_DIR


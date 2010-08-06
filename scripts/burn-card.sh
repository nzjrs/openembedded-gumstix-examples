#!/bin/bash
KERNEL_DIR=/media/OVERO_BOOT
ROOTFS_DIR=/media/OVERO_ROOT

UBOOT=u-boot-overo.bin
MLO=MLO-overo-201008032044

IMAGE=uImage-overo.bin
ROOTFS=omap3-console-image-overo.tar.bz2

echo "===== OVERO BURN SD CARD"

export `bitbake -e 2>/dev/null | grep "^TOPDIR=" | sed 's/"//g'`
export `bitbake -e 2>/dev/null | grep "^DEPLOY_DIR_IMAGE=" | sed 's/"//g'`
export `bitbake -e 2>/dev/null | grep "^DL_DIR=" | sed 's/"//g'`

if [ -z $TOPDIR ] ; then
    echo "ERROR: OE environment not found"
    exit 1
fi

if [ -z $DEPLOY_DIR_IMAGE ] ; then
    echo "ERROR: OE deployment dir not found"
    exit 1
fi

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

MODULES=$DEPLOY_DIR_IMAGE/modules-`readlink $DEPLOY_DIR_IMAGE/$IMAGE | sed 's/uImage-//' | sed 's/.bin//'`.tgz
if [ ! -f $MODULES ] ; then
    echo "ERROR: Kernel modules not found ($MODULES)"
    exit 1
fi

MODULES_FILE=$(basename $MODULES)
IMAGE_FILE=$(readlink $DEPLOY_DIR_IMAGE/$IMAGE)
UBOOT_FILE=$(readlink $DEPLOY_DIR_IMAGE/$UBOOT)

echo "SUMMARY:"
echo "    kernel: $IMAGE_FILE"
echo "    kernel modules: $MODULES_FILE"
echo "    uboot: $UBOOT_FILE"
echo "    MLO: $MLO"
echo "    kernel dir: $KERNEL_DIR"
echo "    rootfs dir: $ROOTFS_DIR"
echo

echo "Clear existing FS on $ROOTFS_DIR (Y/N)"

read -n 1 -s ky
if [ "$ky" == "Y" ] ; then
    echo "===== DELETING ROOT FILE SYSTEM"
    sudo rm -rf $ROOTFS_DIR/*
fi

echo "Extract rootfs to $ROOTFS_DIR (Y/N)"

read -n 1 -s ky
if [ "$ky" == "Y" ] ; then
    echo "===== EXTRACTING ROOT FILE SYSTEM"
    sudo tar xjvf $DEPLOY_DIR_IMAGE/$ROOTFS -C $ROOTFS_DIR > /tmp/extract.log
fi

echo "Extract kernel modules to $ROOTFS_DIR (Y/N)"
read -n 1 -s km
if [ "$km" == "Y" ] ; then
    echo "===== EXTRACTING KERNEL MODULES"
    sudo tar xvzf $MODULES -C $ROOTFS_DIR >> /tmp/extract.log
fi

cp /tmp/extract.log .

echo "Copy MLO to $KERNEL_DIR (Y/N)"
read -n 1 -s mlo
if [ "$mlo" == "Y" ] ; then
    echo "===== COPYING MLO"
    cp $DL_DIR/$MLO $KERNEL_DIR/MLO
fi

echo "Copy u-boot to $KERNEL_DIR (Y/N)"
read -n 1 -s ubt
if [ "$ubt" == "Y" ] ; then
    echo "===== COPYING U-BOOT"
    cp $DEPLOY_DIR_IMAGE/$UBOOT $KERNEL_DIR/u-boot.bin
fi

echo "Copy kernel to $KERNEL_DIR (Y/N)"
read -n 1 -s rfsy
if [ "$rfsy" == "Y" ] ; then
    echo "===== COPYING KERNEL"
    cp $DEPLOY_DIR_IMAGE/$IMAGE $KERNEL_DIR/uImage
fi

echo "Copy overlay to $ROOTFS_DIR (Y/N)"
read -n 1 -s ol
if [ "$ol" == "Y" ] ; then
    echo "===== COPYING OVERLAY"
    sudo rsync -avL $TOPDIR/overlay/ $ROOTFS_DIR
fi

echo "===== UNMOUNTING ROOT FILE SYSTEM"
sudo umount $ROOTFS_DIR
echo "===== UNMOUNTING KERNEL"
sudo umount $KERNEL_DIR


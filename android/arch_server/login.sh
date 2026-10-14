#!/system/bin/sh
# ----------------------------------------------------------------
# CHROOT LOGIN SCRIPT
# A simple script to enter the Arch Linux chroot environment.
# Assumes core mounts are already active from boot scripts.
# ----------------------------------------------------------------
ARCH_PATH="/data/local/tmp/arch"

# A lightweight check to ensure essential mounts are active before entry.
mountpoint -q $ARCH_PATH/proc || mount --bind /proc $ARCH_PATH/proc
mountpoint -q $ARCH_PATH/sys  || mount --bind /sys $ARCH_PATH/sys
mountpoint -q $ARCH_PATH/dev  || mount --bind /dev $ARCH_PATH/dev

# Log into the chroot as user 'nc' with the fish shell
chroot $ARCH_PATH /usr/bin/su - nc -s /usr/bin/fish

#!/system/bin/sh
# ----------------------------------------------------------------
# SCRIPT 00: CORE STARTUP CONFIGURATION
# Executed first. Sets up the Arch Linux chroot mounts and basic
# Android networking permissions for the chroot environment.
# ----------------------------------------------------------------

# Path to the chroot directory
ARCH_PATH="/data/local/tmp/arch"

# Give the system some time to settle after boot
sleep 15

# --- ANDROID SYSTEM PREP ---

# Enable ADB over TCP/IP for remote debugging access
setprop service.adb.tcp.port 5555
stop adbd
start adbd


# --- CHROOT FOUNDATION ---

# Create core directories for chroot environment if they don't exist
mkdir -p $ARCH_PATH/dev $ARCH_PATH/sys $ARCH_PATH/proc $ARCH_PATH/mnt/hdd

# Ensure data partition is mounted with suid and dev permissions, required for chroot
mount -o remount,dev,suid /data

# Mount essential virtual filesystems into the chroot environment.
# Using 'mountpoint -q' ensures we don't try to re-mount if already mounted.
mountpoint -q $ARCH_PATH/dev     || mount --bind /dev $ARCH_PATH/dev
mountpoint -q $ARCH_PATH/sys     || mount --bind /sys $ARCH_PATH/sys
mountpoint -q $ARCH_PATH/proc    || mount --bind /proc $ARCH_PATH/proc
mountpoint -q $ARCH_PATH/dev/pts || mount -t devpts devpts $ARCH_PATH/dev/pts


# --- CHROOT NETWORKING PERMISSIONS ---

# Add key users inside the chroot to Android's network groups.
# This is CRITICAL for allowing chrooted processes to access the network.
# - GID 3003: 'inet', required for creating internet sockets.
# - GID 3004: 'net_raw', required for raw sockets (used by ping, etc.).
chroot $ARCH_PATH /usr/bin/usermod -a -G 3003,3004 root 2>/dev/null || true
chroot $ARCH_PATH /usr/bin/usermod -a -G 3003,3004 nc 2>/dev/null || true # 'nc' is your user
chroot $ARCH_PATH /usr/bin/usermod -a -G 3003,3004 git 2>/dev/null || true


# --- START CORE SERVICES ---

# Start the SSH daemon inside the chroot for remote access
if ! chroot $ARCH_PATH pgrep -x sshd >/dev/null; then
    chroot $ARCH_PATH /usr/bin/sshd
fi

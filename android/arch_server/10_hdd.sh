#!/system/bin/sh
# ----------------------------------------------------------------
# SCRIPT 10: HDD AUTO-MOUNT DAEMON
# Runs as a background process to continuously monitor and manage
# the external HDD mount, ensuring it remains available to the chroot.
# ----------------------------------------------------------------

# Wait for the system and USB hub to initialize
sleep 20

(
    ARCH_PATH="/data/local/tmp/arch"
    HDD_BLOCK_PARTITION="/dev/block/sdh1" # Assumes HDD partition is sdh1
    HDD_BLOCK_DEVICE="/dev/block/sdh"     # The physical disk for hdparm
    MOUNT_TARGET="$ARCH_PATH/mnt/hdd"

    while true; do
        # 1. CHECK IF THE HDD HARDWARE IS CONNECTED
        if [ -b "$HDD_BLOCK_PARTITION" ]; then

            # 2. IF NOT MOUNTED, INITIATE RECOVERY AND REMOUNT
            if ! mountpoint -q "$MOUNT_TARGET"; then
                echo "HDD at $MOUNT_TARGET not mounted. Attempting recovery..."

                # Stop web services to release file locks on the HDD
                chroot $ARCH_PATH /usr/bin/killall nginx php-fpm >/dev/null 2>&1

                # Forcefully unmount any stale references from Android's media scanner
                umount -l /storage/*/* >/dev/null 2>&1

                # Forcefully unmount any lingering mount from the target path
                umount -f "$MOUNT_TARGET" >/dev/null 2>&1
                umount -l "$MOUNT_TARGET" >/dev/null 2>&1
                sleep 1

                # (Optional) Check and repair filesystem. Use with caution.
                # e2fsck -p $HDD_BLOCK_PARTITION >/dev/null 2>&1

                # 3. MOUNT THE DRIVE EXCLUSIVELY FOR THE CHROOT
                # 'noatime' is a performance optimization (disables write timestamps for reads)
                mount -t ext4 -o rw,noatime "$HDD_BLOCK_PARTITION" "$MOUNT_TARGET"

                # 4. POST-MOUNT SETUP
                if mountpoint -q "$MOUNT_TARGET"; then
                    echo "HDD successfully remounted. Setting permissions and restarting services."
                    # Set ownership for user data, git repos, and Nextcloud data
                    chroot $ARCH_PATH /usr/bin/chown nc:nc /mnt/hdd 2>/dev/null
                    [ -d "$MOUNT_TARGET/repos" ] && chroot $ARCH_PATH /usr/bin/chown -R git:git /mnt/hdd/repos 2>/dev/null
                    [ -d "$MOUNT_TARGET/nextcloud_data" ] && chroot $ARCH_PATH /usr/bin/chown -R http:http /mnt/hdd/nextcloud_data 2>/dev/null

                    # Set HDD to spin down after 10 minutes (120 * 5s = 600s) of inactivity
                    [ -b "$HDD_BLOCK_DEVICE" ] && chroot $ARCH_PATH /usr/bin/hdparm -S 120 $HDD_BLOCK_DEVICE > /dev/null 2>&1

                    # Restart web services
                    chroot $ARCH_PATH /usr/bin/php-fpm
                    chroot $ARCH_PATH /usr/bin/nginx
                fi
            fi
        fi
        # Check status every 10 seconds
        sleep 10
    done
) &

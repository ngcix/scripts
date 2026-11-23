#!/system/bin/sh

ROOT=/data/local/tmp/arch
LOG=/data/local/tmp/arch-init.log          # general / boot messages
HDD_LOG=/data/local/tmp/arch-hdd.log       # HDD mount + connect/disconnect
NET_LOG=/data/local/tmp/arch-net.log       # ip commands, connection loss/reset
CHROOT_LOG=/data/local/tmp/arch-chroot.log # commands run inside the chroot
HDD_BLOCK="/dev/block/sdh1"
HDD_DISK="/dev/block/sdh"
MOUNT_TARGET="$ROOT/mnt/hdd"

exec >>"$LOG" 2>&1
echo "=== $(date) ==="

until [ "$(getprop sys.boot_completed)" = 1 ]; do
    sleep 1
done

svc power stayon true
dumpsys deviceidle disable
settings put global low_power 0

stop
sleep 3

# LAN
ip link set eth0 up >>"$NET_LOG" 2>&1
ip addr add 192.168.1.69/24 dev eth0 >>"$NET_LOG" 2>&1 || true
ip route add default via 192.168.1.1 dev eth0 >>"$NET_LOG" 2>&1 || true

# ADB TCP.
setprop service.adb.tcp.port 5555
stop adbd
start adbd

################################################################################

mkdir -p "$ROOT"/{dev/pts,dev/shm,proc,sys,run,sdcard}
mount -o remount,dev,suid /data

# Make the chroot root a real mount point (docker/containerd need "/" in mountinfo
# and remount it rprivate). Must happen before all other mounts below.
mountpoint -q "$ROOT" || mount --bind "$ROOT" "$ROOT"

mountpoint -q "$ROOT/dev" || mount --bind /dev "$ROOT/dev"
mountpoint -q "$ROOT/dev/pts" || mount -t devpts devpts "$ROOT/dev/pts"
mountpoint -q "$ROOT/dev/shm" || mount -t tmpfs -o mode=1777,size=256M tmpfs "$ROOT/dev/shm"
mountpoint -q "$ROOT/proc" || mount -t proc proc "$ROOT/proc"
mountpoint -q "$ROOT/sys" || mount --bind /sys "$ROOT/sys"
mountpoint -q "$ROOT/run" || mount -t tmpfs -o mode=755,size=64M tmpfs "$ROOT/run"
mountpoint -q "$ROOT/sdcard" || mount --bind /sdcard "$ROOT/sdcard"

# Service manager: dinit (system mode, container = no PID1/shutdown duties).
# Services live in $ROOT/etc/dinit.d ; manage with: sudo dinitctl status|start|stop|restart <svc>
CHROOT_ENV="/usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/bin HOME=/root LANG=C.UTF-8"
chroot $ROOT $CHROOT_ENV /usr/bin/dinit --system --container \
    --services-dir /etc/dinit.d --socket-path /run/dinitctl >>"$CHROOT_LOG" 2>&1 &

# Fallback: if dinit didn't bring up sshd + tailscaled, start them the old way
sleep 20
if ! chroot $ROOT $CHROOT_ENV /usr/bin/dinitctl --quiet is-started sshd 2>/dev/null ||
   ! chroot $ROOT $CHROOT_ENV /usr/bin/dinitctl --quiet is-started tailscaled 2>/dev/null; then
    echo "$(date): dinit failed -> legacy start of tailscaled/sshd"
    chroot $ROOT /usr/bin/mkdir -p /run/tailscale /var/lib/tailscale >>"$CHROOT_LOG" 2>&1
    pgrep -f 'tailscaled --tun' >/dev/null || chroot $ROOT /usr/bin/tailscaled --tun=userspace-networking >>"$CHROOT_LOG" 2>&1 &
    pgrep -f '/usr/bin/sshd' >/dev/null || chroot $ROOT /usr/bin/sshd >>"$CHROOT_LOG" 2>&1
fi

echo "Arch chroot initialized"
setprop sys.arch.init_done 1   # signals 01_net_tune.sh

################################################################################

# HDD mount with resilience fixes for JMicron USB-SATA bridge
(
    while true; do
        if [ -b "$HDD_BLOCK" ]; then
            if ! mountpoint -q "$MOUNT_TARGET"; then
                # Clean up any stale mounts
                umount -f "$MOUNT_TARGET" >/dev/null 2>&1
                umount -l "$MOUNT_TARGET" >/dev/null 2>&1

                # Mount HDD with noatime to reduce I/O wear
                mount -t ext4 -o rw,noatime,context=u:object_r:sdcard_posix:s0 "$HDD_BLOCK" "$MOUNT_TARGET" >>"$HDD_LOG" 2>&1

                # Reduce SCSI device spindown timeout (prevent aggressive PM)
                if [ -b "$HDD_DISK" ]; then
                    chroot $ROOT /usr/bin/hdparm -S 120 $HDD_DISK >>"$CHROOT_LOG" 2>&1
                    echo "$(date '+%Y-%m-%d %H:%M:%S'): HDD mounted and spindown disabled" >> "$HDD_LOG"
                fi
            fi
        else
            # HDD is not connected - clean up mount if it exists
            if mountpoint -q "$MOUNT_TARGET"; then
                echo "$(date '+%Y-%m-%d %H:%M:%S'): HDD DISCONNECTED - cleaning up mount" >> "$HDD_LOG"
                umount -l "$MOUNT_TARGET" >/dev/null 2>&1
            fi
        fi
        sleep 10
    done
) &

# Monitor HDD for unexpected disconnects and log state
(
    LAST_STATE="unknown"
    while true; do
        if [ -b "$HDD_BLOCK" ]; then
            if [ "$LAST_STATE" != "connected" ]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S'): HDD connected" >> "$HDD_LOG"
                LAST_STATE="connected"
            fi
        else
            if [ "$LAST_STATE" != "disconnected" ]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S'): HDD DISCONNECTED - /dev/block/sdh1 missing" >> "$HDD_LOG"
                # Log current state for debugging
                echo "=== USB Devices ===" >> "$HDD_LOG"
                lsusb >> "$HDD_LOG" 2>&1
                echo "=== dmesg tail ===" >> "$HDD_LOG"
                dmesg | tail -50 >> "$HDD_LOG" 2>&1
                LAST_STATE="disconnected"
            fi
        fi
        sleep 60
    done
) &

################################################################################

(
    LAST_STATE="disconnected"
    while true; do
        sleep 60
        if ! ping -c 1 -W 2 192.168.1.1 >/dev/null 2>&1; then
            if [ "$LAST_STATE" != "disconnected" ]; then
                echo "$(date): Lost connection" >> "$NET_LOG"
                LAST_STATE="disconnected"
            fi
            echo "$(date): resetting eth0..." >> "$NET_LOG"
            ip link set eth0 down >>"$NET_LOG" 2>&1
            sleep 1
            ip link set eth0 up >>"$NET_LOG" 2>&1
            ip addr add 192.168.1.69/24 dev eth0 >>"$NET_LOG" 2>&1 || true
            ip route add default via 192.168.1.1 dev eth0 >>"$NET_LOG" 2>&1 || true
        else
            LAST_STATE="connected"
        fi
    done
) &

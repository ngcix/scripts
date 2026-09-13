#!/system/bin/sh

ROOT=/data/local/tmp/arch
LOG=/data/local/tmp/arch-init.log
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
ip link set eth0 up
ip addr add 192.168.1.169/24 dev eth0 2>/dev/null || true
ip route add default via 192.168.1.1 dev eth0 2>/dev/null || true

# ADB TCP.
setprop service.adb.tcp.port 5555
stop adbd
start adbd

################################################################################

mkdir -p "$ROOT"/{dev/pts,dev/shm,proc,sys,run,sdcard}

mountpoint -q "$ROOT/dev" || mount --bind /dev "$ROOT/dev"
mountpoint -q "$ROOT/dev/pts" || mount -t devpts devpts "$ROOT/dev/pts"
mountpoint -q "$ROOT/dev/shm" || mount -t tmpfs -o mode=1777,size=256M tmpfs "$ROOT/dev/shm"
mountpoint -q "$ROOT/proc" || mount -t proc proc "$ROOT/proc"
mountpoint -q "$ROOT/sys" || mount --bind /sys "$ROOT/sys"
mountpoint -q "$ROOT/run" || mount -t tmpfs -o mode=755,size=64M tmpfs "$ROOT/run"
mountpoint -q "$ROOT/sdcard" || mount --bind /sdcard "$ROOT/sdcard"

chroot $ROOT /usr/bin/mkdir -p /var/run/tailscale /var/lib/tailscale
chroot $ROOT /usr/bin/tailscaled --tun=userspace-networking 2>&1 > /dev/null &
sleep 3
chroot $ROOT /usr/bin/tailscale up
chroot $ROOT /usr/bin/sshd

echo "Arch chroot initialized"

################################################################################

(
    while true; do
        if [ -b "$HDD_BLOCK" ]; then
            if ! mountpoint -q "$MOUNT_TARGET"; then
                umount -f "$MOUNT_TARGET" >/dev/null 2>&1
                umount -l "$MOUNT_TARGET" >/dev/null 2>&1

                mount -t ext4 -o rw,noatime,context=u:object_r:sdcard_posix:s0 "$HDD_BLOCK" "$MOUNT_TARGET"
                [ -b "$HDD_DISK" ] && chroot $ROOT /usr/bin/hdparm -S 120 $HDD_DISK > /dev/null 2>&1
            fi
        fi
        sleep 5
    done
) &

################################################################################

(
    while true; do
        sleep 30
        if ! ping -c 1 -W 2 192.168.1.1 >/dev/null 2>&1; then
            echo "$(date): Lost connection, resetting eth0..."
            ip link set eth0 down
            sleep 1
            ip link set eth0 up
            ip addr add 192.168.1.69/24 dev eth0 2>/dev/null || true
            ip route add default via 192.168.1.1 dev eth0 2>/dev/null || true
        fi
    done
) &


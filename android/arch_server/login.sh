#!/bin/sh
PATHS="/data/local/tmp/arch"

mkdir -p $PATHS/dev $PATHS/sys $PATHS/proc $PATHS/sdcard $PATHS/dev/shm $PATHS/dev/pts

mount -o remount,dev,suid /data

# Cơ chế bảo hiểm chặn đứng drop mountpoint khi tương tác tay
mountpoint -q $PATHS/dev     || mount --bind /dev $PATHS/dev
mountpoint -q $PATHS/sys     || mount --bind /sys $PATHS/sys
mountpoint -q $PATHS/proc    || mount --bind /proc $PATHS/proc
mountpoint -q $PATHS/dev/pts || mount -t devpts devpts $PATHS/dev/pts
mountpoint -q $PATHS/dev/shm || mount -t tmpfs -o size=256M tmpfs $PATHS/dev/shm
mountpoint -q $PATHS/sdcard  || mount --bind /sdcard $PATHS/sdcard

# Đồng bộ nhẹ phân quyền phòng khi có cập nhật hệ thống từ phía Android
chroot $PATHS /usr/bin/usermod -a -G 3003,3004 root 2>/dev/null || true
chroot $PATHS /usr/bin/usermod -a -G 3003,3004 nc 2>/dev/null || true
chroot $PATHS /usr/bin/usermod -a -G 3003,3004 git 2>/dev/null || true

# Khóa cứng luồng xử lý mạng vào các nhân CPU to
RPS_FILE=$(find /sys/class/net/eth0/ -name "rps_cpus" 2>/dev/null)
[ ! -z "$RPS_FILE" ] && echo "ff" > "$RPS_FILE" 2>/dev/null || true

# Đăng nhập thẳng vào shell cá nhân của bạn
chroot $PATHS /usr/bin/su - nc -s /usr/bin/fish

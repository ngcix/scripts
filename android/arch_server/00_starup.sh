#!/system/bin/sh
# ----------------------------------------------------------------
# CORE STARTUP CONFIGURATION FOR ANDROID & ARCH LINUX CHROOT
# ----------------------------------------------------------------
PATHS="/data/local/tmp/arch"

# Chờ hệ thống Android boot ổn định tí chút
sleep 10

# Bật tính năng mạng ADB qua TCP/IP
setprop service.adb.tcp.port 5555
stop adbd
start adbd

# KHỞI TẠO NỀN MÓNG CHROOT (Phải mount core trước khi các script khác gọi chroot)
mkdir -p $PATHS/dev $PATHS/sys $PATHS/proc $PATHS/sdcard $PATHS/dev/shm $PATHS/dev/pts
mount -o remount,dev,suid /data
mountpoint -q $PATHS/dev     || mount --bind /dev $PATHS/dev
mountpoint -q $PATHS/sys     || mount --bind /sys $PATHS/sys
mountpoint -q $PATHS/proc    || mount --bind /proc $PATHS/proc
mountpoint -q $PATHS/dev/pts || mount -t devpts devpts $PATHS/dev/pts

# ĐỢI THIẾT BỊ MẠNG ETH0 LÊN ĐỂ TỐI ƯU GIGABIT
for i in $(seq 1 10); do
    if ifconfig eth0 >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

if ifconfig eth0 >/dev/null 2>&1; then
    ifconfig eth0 txqueuelen 3000
    RPS_FILE=$(find /sys/class/net/eth0/ -name "rps_cpus" 2>/dev/null)
    [ ! -z "$RPS_FILE" ] && echo "ff" > "$RPS_FILE" 2>/dev/null || true
fi

# ÉP QUYỀN MẠNG ANDROID CHO CÁC USER TRONG ARCH
chroot $PATHS /usr/bin/usermod -a -G 3003,3004 root 2>/dev/null || true
chroot $PATHS /usr/bin/usermod -a -G 3003,3004 nc 2>/dev/null || true
chroot $PATHS /usr/bin/usermod -a -G 3003,3004 git 2>/dev/null || true

# KHỞI ĐỘNG GIT SERVER (SSHD)
if ! chroot $PATHS pgrep -x sshd >/dev/null; then
    chroot $PATHS /usr/bin/sshd
fi

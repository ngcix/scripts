#!/system/bin/sh
# Chờ 15 giây để Kernel nhận diện xong Dock/Hub USB
sleep 15

ARCH_PATH="/data/local/tmp/arch"
HDD_BLOCK="/dev/block/sdh1"
HDD_DISK="/dev/block/sdh"

# 1. MOUNT HDD KÈM CONFIG SELINUX
if [ -b "$HDD_BLOCK" ]; then
    mkdir -p $ARCH_PATH/mnt/hdd
    mountpoint -q $ARCH_PATH/mnt/hdd || mount -t ext4 -o rw,noatime,context=u:object_r:sdcard_posix:s0 $HDD_BLOCK $ARCH_PATH/mnt/hdd
    
    # Lúc này chroot gọi chown sẽ chạy hoàn hảo vì /proc và /sys đã được 00_startup chuẩn bị
    chroot $ARCH_PATH /usr/bin/chown -R nc:nc /mnt/hdd 2>/dev/null
fi

# 2. ĐỒNG BỘ QUYỀN SỞ HỮU TRÊN HDD CHO USER GIT (ĐỂ SYMLINK REPOS HOẠT ĐỘNG CHUẨN)
if [ -d "$ARCH_PATH/mnt/hdd/repos" ]; then
    chroot $ARCH_PATH /usr/bin/chown -R git:git /mnt/hdd/repos 2>/dev/null || true
fi

# 3. SET TIMER SLEEP CHO Ổ CỨNG
if [ -b "$HDD_DISK" ]; then
    chroot $ARCH_PATH /usr/bin/hdparm -S 120 $HDD_DISK > /dev/null 2>&1
fi



======================

#!/system/bin/sh
# ----------------------------------------------------------------
# SMART AUTO-REMOUNT DAEMON FOR HDD (ANTI-DISCONNECT)
# ----------------------------------------------------------------
ARCH_PATH="/data/local/tmp/arch"
HDD_BLOCK="/dev/block/sdh1"
HDD_DISK="/dev/block/sdh"
MOUNT_TARGET="$ARCH_PATH/mnt/hdd"

# Chờ 15 giây đầu lúc boot để Hub ổn định
sleep 15

while true; do
    # 1. KIỂM TRA PHẦN CỨNG Ổ CỨNG CÓ CẮM TRÊN MÁY KHÔNG
    if [ -b "$HDD_BLOCK" ]; then
        
        # 2. KIỂM TRA XEM Ổ CỨNG ĐÃ ĐƯỢC MOUNT VÀO ARCH CHƯA
        if ! mountpoint -q "$MOUNT_TARGET"; then
            # Nếu chưa mount (hoặc bị rớt mount do rút sạc), tiến hành dọn dẹp biến treo
            umount -f "$MOUNT_TARGET" >/dev/null 2>&1
            umount -l "$MOUNT_TARGET" >/dev/null 2>&1
            mkdir -p "$MOUNT_TARGET"

            # Thực hiện Mount lại kèm cấu hình SELinux cho Android
            mount -t ext4 -o rw,noatime,context=u:object_r:sdcard_posix:s0 "$HDD_BLOCK" "$MOUNT_TARGET"
            
            # Đồng bộ lại phân quyền cho các user bên trong Arch
            chroot $ARCH_PATH /usr/bin/chown nc:nc /mnt/hdd 2>/dev/null
            if [ -d "$MOUNT_TARGET/repos" ]; then
                chroot $ARCH_PATH /usr/bin/chown -R git:git /mnt/hdd/repos 2>/dev/null || true
            fi
            if [ -d "$MOUNT_TARGET/nextcloud_data" ]; then
                chroot $ARCH_PATH /usr/bin/chown -R http:http /mnt/hdd/nextcloud_data 2>/dev/null || true
            fi
            
            # Đặt lại timer ngủ đông cho ổ cứng (SATA-to-USB vừa bị reset nên phải nạp lại lệnh này)
            if [ -b "$HDD_DISK" ]; then
                chroot $ARCH_PATH /usr/bin/hdparm -S 120 $HDD_DISK > /dev/null 2>&1
            fi

            # Khởi động lại dịch vụ Web Cloud để nhận diện lại ổ cứng sạch sẽ
            chroot $ARCH_PATH /usr/bin/killall nginx php-fpm >/dev/null 2>&1
            chroot $ARCH_PATH /usr/bin/php-fpm
            chroot $ARCH_PATH /usr/bin/nginx
        fi
    fi
    
    # Cứ 5 giây quét một lần để canh gác trạng thái kết nối
    sleep 5
done &
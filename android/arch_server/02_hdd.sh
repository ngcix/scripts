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
            # 1. Ép các dịch vụ Web của Arch dừng lại để nhả file descriptor
            chroot $ARCH_PATH /usr/bin/killall nginx php-fpm >/dev/null 2>&1
            
            # 2. ĐÁNH CHẶN ANDROID: Ép Android buông tha cho phân vùng sdh1
            #umount -l /storage/*/* >/dev/null 2>&1
            #umount -l /mnt/media_rw/* >/dev/null 2>&1
            #fuser -k -m /dev/block/sdh1 >/dev/null 2>&1
            
            # 3. Tháo điểm mount cũ đang bị lỗi của Arch
            umount -f "$MOUNT_TARGET" >/dev/null 2>&1
            umount -l "$MOUNT_TARGET" >/dev/null 2>&1
            sleep 1
            
            # 4. Sửa lỗi hệ thống file (Fix tổn thương do rút sạc)
            #e2fsck -p /dev/block/sdh1 >/dev/null 2>&1
            
            # 5. Mount độc quyền lại vào Arch Linux
            mount -t ext4 -o rw,noatime,context=u:object_r:sdcard_posix:s0 "$HDD_BLOCK" "$MOUNT_TARGET"
            
            # [Các lệnh chown, hdparm, và khởi động lại nginx/php-fpm giữ nguyên phía dưới...]
            chroot $ARCH_PATH /usr/bin/chown nc:nc /mnt/hdd 2>/dev/null
            [ -d "$MOUNT_TARGET/repos" ] && chroot $ARCH_PATH /usr/bin/chown -R git:git /mnt/hdd/repos 2>/dev/null
            [ -d "$MOUNT_TARGET/nextcloud_data" ] && chroot $ARCH_PATH /usr/bin/chown -R http:http /mnt/hdd/nextcloud_data 2>/dev/null
            [ -b "$HDD_DISK" ] && chroot $ARCH_PATH /usr/bin/hdparm -S 120 $HDD_DISK > /dev/null 2>&1
            
            chroot $ARCH_PATH /usr/bin/php-fpm
            chroot $ARCH_PATH /usr/bin/nginx
        fi
    fi
    
    # Cứ 5 giây quét một lần để canh gác trạng thái kết nối
    sleep 5
done &
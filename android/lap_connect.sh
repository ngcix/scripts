#!/data/data/com.termux/files/usr/bin/bash

# Cấu hình
HOSTS=("192.168.1.2")  # Thay bằng IP LAN và IP WiFi của máy 1, hoặc hostname nếu có
USER="ntc"  # Tên user SSH trên máy 1
PORT=22
INTERVAL=30  # Thời gian thử lại (giây)
TIMEOUT=10   # Timeout kết nối (giây)

echo "Bắt đầu kiểm tra SSH đến máy 1. Nhấn Ctrl+C để dừng."

while true; do
    for host in "${HOSTS[@]}"; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Thử kết nối đến $host:$PORT..."
        
        # Thử kết nối SSH (cần password hoặc key; nếu chỉ kiểm tra port, dùng nc thay thế)
        if ssh -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no -p $PORT -R 2222:localhost:2222 \
        -R 3333:localhost:2222 \
         $USER@$host "echo 'Kết nối thành công!'" 2>/dev/null; then
            echo "✓ Kết nối SSH thành công đến $host!"
            # Nếu muốn tự động chạy lệnh sau khi kết nối, thêm ở đây (ví dụ: ssh ... 'ls /home')
        else
            # Fallback: Kiểm tra port bằng netcat nếu SSH fail
            if nc -z -w $TIMEOUT $host $PORT 2>/dev/null; then
                echo "⚠ Port SSH mở trên $host nhưng kết nối user fail (kiểm tra password/key)."
            else
                echo "✗ Không kết nối được đến $host (port đóng hoặc offline)."
            fi
        fi
    done
    
    echo "Chờ $INTERVAL giây trước lần thử tiếp theo..."
    sleep $INTERVAL
done

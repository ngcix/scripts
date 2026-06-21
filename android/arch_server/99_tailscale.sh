#!/system/bin/sh
# Khởi động muộn nhất để đợi HDD và mạng LAN đã ổn định hoàn toàn
sleep 20

ARCH_PATH="/data/local/tmp/arch"

# Tạo thư mục runtime cho tailscale bên trong chroot
chroot $ARCH_PATH /usr/bin/mkdir -p /var/run/tailscale /var/lib/tailscale

# Kích nổ tailscaled nền userspace
chroot $ARCH_PATH /usr/bin/tailscaled --tun=userspace-networking 2>&1 > /dev/null &

# Chờ daemon ổn định rồi kéo link kết nối vĩnh viễn
sleep 3
chroot $ARCH_PATH /usr/bin/tailscale up
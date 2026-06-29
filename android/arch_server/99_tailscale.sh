#!/system/bin/sh
sleep 20

ARCH_PATH="/data/local/tmp/arch"

chroot $ARCH_PATH /usr/bin/mkdir -p /var/run/tailscale /var/lib/tailscale

chroot $ARCH_PATH /usr/bin/tailscaled --tun=userspace-networking 2>&1 > /dev/null &

sleep 3
chroot $ARCH_PATH /usr/bin/tailscale up
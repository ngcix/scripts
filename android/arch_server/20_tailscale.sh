#!/system/bin/sh
# ----------------------------------------------------------------
# SCRIPT 20: TAILSCALE DAEMON STARTUP
# Starts the Tailscale daemon inside the chroot.
# Runs after core setup and HDD are likely available.
# ----------------------------------------------------------------

# Wait for core networking to be stable
sleep 30

ARCH_PATH="/data/local/tmp/arch"

# Ensure runtime directories for tailscaled exist inside the chroot
chroot $ARCH_PATH /usr/bin/mkdir -p /var/run/tailscale /var/lib/tailscale

# Start the Tailscale daemon in the background
# '--tun=userspace-networking' is required for non-root, chroot environments
chroot $ARCH_PATH /usr/bin/tailscaled --tun=userspace-networking 2>&1 > /dev/null &

# Wait for the daemon to initialize
sleep 5

# Bring the Tailscale connection up
chroot $ARCH_PATH /usr/bin/tailscale up


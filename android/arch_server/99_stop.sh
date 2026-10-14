#!/system/bin/sh
# ----------------------------------------------------------------
# SCRIPT 99: HEADLESS SERVER TRANSFORMATION
# This is the final boot script. It configures a static IP for
# the Ethernet interface and then stops the Android Framework (UI).
# ----------------------------------------------------------------

# Wait a long time to ensure everything else is fully initialized.
sleep 60

# --- ETHERNET & NETWORK OPTIMIZATIONS ---
# These are safe to run again.
if ifconfig eth0 >/dev/null 2>&1; then
    # Increase transmit queue length for better high-throughput performance
    ifconfig eth0 txqueuelen 3000

    # Enable Receive Packet Steering (RPS) to distribute network processing
    # across all CPU cores ('ff' = CPU cores 0-7) for better performance.
    RPS_FILE=$(find /sys/class/net/eth0/ -name "rps_cpus" 2>/dev/null)
    [ ! -z "$RPS_FILE" ] && echo "ff" > "$RPS_FILE" 2>/dev/null || true
fi


# --- STATIC IP CONFIGURATION (CRITICAL) ---
# This section prevents network loss after `stop` is called.

# Ensure the ethernet interface is up
ip link set eth0 up

# Flush any existing IP configuration from Android's DHCP client
ip addr flush dev eth0

# Assign the static IP address, subnet mask, and default gateway.
# !! CHANGE THESE VALUES TO MATCH YOUR LOCAL NETWORK !!
ip addr add 192.168.1.69/24 dev eth0
ip route replace default via 192.168.1.1 dev eth0

# Set DNS servers using Android properties. This is the correct way
# to provide DNS to the entire system, including the chroot.
setprop net.dns1 1.1.1.1
setprop net.dns2 8.8.8.8


# --- INITIATE HEADLESS MODE ---

# Stop the entire Android Framework (Zygote, SystemServer, UI, etc.)
# The phone is now a pure Linux server with networking handled by the kernel.
stop

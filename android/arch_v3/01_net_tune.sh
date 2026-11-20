#!/system/bin/sh
# Network throughput tuning for USB LAN (AX88179B on xHCI/dwc3).
# Bottleneck: ax88179 on this 4.14 kernel has no SG/TSO -> one URB per packet,
# all completions handled in the xHCI hardirq on a single CPU. We pin that IRQ
# to the fastest core (cpu7) and stop the things that keep moving it away.
#
# Waits for 00_init.sh to set sys.arch.init_done=1, then re-applies every 30s
# (LAN reset / USB re-enumeration / core_ctl can undo settings).

LOG=/data/local/tmp/arch-tune.log
IRQ_CPU=7          # prime core (2.84 GHz)
RPS_MASK=70        # RX packet steering to big cores cpu4-6 (little cores -> ~550 Mbps flows), cpu7 keeps the IRQ

exec >>"$LOG" 2>&1
echo "=== $(date) === waiting for init"

until [ "$(getprop sys.arch.init_done)" = 1 ]; do
    sleep 2
done
echo "$(date): init done, tuning"

# One-shot settings
stop vendor.msm_irqbalance      # it moves the xHCI IRQ back to little cores

sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"
sysctl -w net.core.netdev_max_backlog=10000

apply() {
    # Keep big cores online (core_ctl isolates them -> IRQ gets migrated off)
    echo 3 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus 2>/dev/null
    echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/min_cpus 2>/dev/null

    for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ "$(cat $g)" = performance ] || echo performance > "$g"
    done

    IRQ=$(grep -m1 'xhci-hcd' /proc/interrupts | awk -F: '{gsub(/ /,"",$1); print $1}')
    if [ -n "$IRQ" ] && [ "$(cat /proc/irq/$IRQ/smp_affinity_list)" != "$IRQ_CPU" ]; then
        echo $IRQ_CPU > /proc/irq/$IRQ/smp_affinity_list && echo "$(date): IRQ $IRQ -> cpu$IRQ_CPU"
    fi

    if [ -d /sys/class/net/eth0 ]; then
        [ "$(cat /sys/class/net/eth0/tx_queue_len)" = 3000 ] || echo 3000 > /sys/class/net/eth0/tx_queue_len
        for f in /sys/class/net/eth0/queues/rx-*/rps_cpus; do
            [ "$(cat $f)" = "$RPS_MASK" ] || echo $RPS_MASK > "$f"
        done
    fi
}

while true; do
    apply
    sleep 30
done

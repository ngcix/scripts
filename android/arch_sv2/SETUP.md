# Arch Linux on LG G8 ThinQ - Setup & HDD Stability Fix

## Problem
HDD disconnects after 6+ hours, likely due to JMicron JMS583 USB-SATA bridge firmware issues or SCSI device power management becoming aggressive.

## Root Cause Analysis
- USB device: `2-1.3` = JMicron JMS583 (USB 3 to SATA bridge)
- Device state shows massive I/O errors in sysfs power management files
- Kernel unable to read device state suggests firmware crash or SCSI driver desync
- Autosuspend already disabled (`autosuspend_delay_ms = 0`)

## Solution: One-Time Setup Commands

Run these commands on the Android phone (via adb shell or SSH) to apply permanent fixes:

```bash
# SSH access (or use: adb shell su -c '...')
ssh -p 22 root@192.168.1.169

# Disable HDD spindown (prevent aggressive power cycling)
hdparm -S 0 /dev/block/sdh

# Disable SCSI device power management (prevent start/stop commands)
echo 0 > /sys/class/scsi_disk/1:0:0:0/manage_start_stop

# Increase SCSI command queue depth (handle sustained I/O better)
echo 256 > /sys/class/scsi_host/host1/cmd_per_lun

# Make SCSI error handler less aggressive
echo 600 > /sys/class/scsi_host/host1/eh_deadline

# Disable USB autosuspend for JMicron device
echo -1 > /sys/bus/usb/devices/2-1.3/power/autosuspend_delay_ms
echo on > /sys/bus/usb/devices/2-1.3/power/control
```

### Make Settings Persistent (Optional)

Create a systemd service in the Arch chroot to apply these on boot:

```bash
# SSH into Arch chroot
ssh -p 22 root@192.168.1.169

# Create service file
cat > /etc/systemd/system/hdd-stability.service << 'EOF'
[Unit]
Description=HDD Stability Fixes (JMicron bridge)
After=local-fs-target.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/hdd-stability-fix.sh

[Install]
WantedBy=multi-user.target
EOF

# Create the script
cat > /usr/local/bin/hdd-stability-fix.sh << 'EOF'
#!/bin/bash
set -e

# Exit early if HDD not present (might not be mounted on all boots)
[ -b /dev/block/sdh ] || exit 0

# Disable spindown
hdparm -S 0 /dev/block/sdh >/dev/null 2>&1 || true

# SCSI fixes
echo 0 > /sys/class/scsi_disk/1:0:0:0/manage_start_stop 2>/dev/null || true
echo 256 > /sys/class/scsi_host/host1/cmd_per_lun 2>/dev/null || true
echo 600 > /sys/class/scsi_host/host1/eh_deadline 2>/dev/null || true

# USB autosuspend fix
echo -1 > /sys/bus/usb/devices/2-1.3/power/autosuspend_delay_ms 2>/dev/null || true
echo on > /sys/bus/usb/devices/2-1.3/power/control 2>/dev/null || true

logger "HDD stability fixes applied"
EOF

chmod +x /usr/local/bin/hdd-stability-fix.sh
systemctl daemon-reload
systemctl enable hdd-stability.service
```

## Improved Monitoring (Already in 00_init.sh)

The init script now:
1. **Auto-mounts HDD** when device appears (every 10 seconds check)
2. **Disables spindown** via hdparm during mount attempt
3. **Logs disconnects** with kernel state for debugging
4. **Tracks state changes** to avoid log spam

## Expected Results After Fixes

- ✅ HDD should remain mounted indefinitely (no 6-hour disconnect)
- ✅ Better handling of sustained read/write load
- ✅ SCSI driver won't aggressively power-cycle the device
- ✅ Detailed logs in `/data/local/tmp/arch-init.log` if issues persist

## Debugging

If HDD still disconnects:

```bash
# Check logs
adb shell cat /data/local/tmp/arch-init.log | tail -50

# Check current state
adb shell su -c 'lsusb | grep 152d'        # HDD controller present?
adb shell su -c 'ls /dev/block/sdh*'       # Device nodes exist?
adb shell su -c 'dmesg | tail -50'         # Kernel error messages?
adb shell su -c 'mount | grep sdh'         # Currently mounted?
```

## Notes

- **HDD has external 12V power** (via dock), so power loss unlikely
- **JMicron controllers known issue:** Some firmware versions have stability problems under:
  - Sustained high I/O load
  - Thermal stress (phone gets hot)
  - Power management thrashing
- If issues persist after these fixes, consider:
  - Firmware update for JMicron bridge (if available from dock manufacturer)
  - Different USB dock / bridge
  - Switching to USB 2.0 HDD (if available) for lower power mode stability

#!/bin/bash
# HDD Stability Fix - Quick Reference
# Run this on the phone (via adb shell or SSH) to apply one-time fixes
# Usage: adb shell su -c 'bash /path/to/HDD_FIX_QUICK.sh'
#    OR: ssh root@<phone-ip> 'bash /path/to/HDD_FIX_QUICK.sh'

set -e

echo "=== Applying HDD Stability Fixes ==="

# 1. Disable HDD spindown via hdparm
echo "1. Disabling HDD spindown (hdparm -S 0)..."
hdparm -S 0 /dev/block/sdh || echo "   ⚠️  hdparm might not be in /system/bin on Android"

# 2. Disable SCSI device manage_start_stop (prevents power cycling bridge)
echo "2. Disabling SCSI manage_start_stop..."
if [ -f /sys/class/scsi_disk/1:0:0:0/manage_start_stop ]; then
    echo 0 > /sys/class/scsi_disk/1:0:0:0/manage_start_stop && echo "   ✓ OK"
else
    echo "   ⚠️  Path not found (device might not be attached)"
fi

# 3. Increase SCSI command queue depth
echo "3. Increasing SCSI cmd_per_lun (256)..."
if [ -f /sys/class/scsi_host/host1/cmd_per_lun ]; then
    echo 256 > /sys/class/scsi_host/host1/cmd_per_lun && echo "   ✓ OK"
else
    echo "   ⚠️  Path not found"
fi

# 4. Make SCSI error handler less aggressive
echo "4. Setting SCSI eh_deadline (600s)..."
if [ -f /sys/class/scsi_host/host1/eh_deadline ]; then
    echo 600 > /sys/class/scsi_host/host1/eh_deadline && echo "   ✓ OK"
else
    echo "   ⚠️  Path not found"
fi

# 5. Disable USB autosuspend for JMicron device
echo "5. Disabling USB autosuspend for JMicron bridge (2-1.3)..."
if [ -d /sys/bus/usb/devices/2-1.3 ]; then
    echo -1 > /sys/bus/usb/devices/2-1.3/power/autosuspend_delay_ms 2>/dev/null || true
    echo on > /sys/bus/usb/devices/2-1.3/power/control 2>/dev/null || true
    echo "   ✓ OK"
else
    echo "   ⚠️  Device not found (HDD might not be connected)"
fi

echo ""
echo "=== Verification ==="
echo "Checking current settings..."

if [ -f /sys/class/scsi_disk/1:0:0:0/manage_start_stop ]; then
    echo "manage_start_stop = $(cat /sys/class/scsi_disk/1:0:0:0/manage_start_stop) (should be 0)"
fi

if [ -f /sys/class/scsi_host/host1/cmd_per_lun ]; then
    echo "cmd_per_lun = $(cat /sys/class/scsi_host/host1/cmd_per_lun) (should be 256)"
fi

if [ -d /sys/bus/usb/devices/2-1.3 ]; then
    echo "autosuspend_delay_ms = $(cat /sys/bus/usb/devices/2-1.3/power/autosuspend_delay_ms) (should be -1)"
fi

echo ""
echo "✅ HDD stability fixes applied!"
echo "Note: These settings are NOT persistent across reboots."
echo "      See SETUP.md for making them persistent via systemd service."

#!/bin/bash
# Quick deployment script - applies all fixes in one go
# Usage: bash QUICK_DEPLOY.sh <phone-ip-or-adb-id>

PHONE="${1:-107.98.150.183:12000}"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  QUICK DEPLOY - HDD FIX FOR ARCH LINUX SETUP             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verify connection
echo "1️⃣  Testing ADB connection..."
if ! adb -s "$PHONE" shell "echo 'OK'" >/dev/null 2>&1; then
    echo "❌ Cannot connect to $PHONE"
    echo "   Usage: $0 <device-id>"
    echo "   Example: $0 107.98.150.183:12000"
    exit 1
fi
echo "✅ Connected to $PHONE"
echo ""

# Apply one-time fixes
echo "2️⃣  Applying SCSI/USB stability fixes..."
adb -s "$PHONE" shell "su -c 'bash -c \"
hdparm -S 0 /dev/block/sdh >/dev/null 2>&1 && echo '   ✓ hdparm spindown disabled' || echo '   ⚠ hdparm failed'
echo 0 > /sys/class/scsi_disk/1:0:0:0/manage_start_stop 2>/dev/null && echo '   ✓ SCSI manage_start_stop = 0' || echo '   ⚠ Failed'
echo 256 > /sys/class/scsi_host/host1/cmd_per_lun 2>/dev/null && echo '   ✓ SCSI cmd_per_lun = 256' || echo '   ⚠ Failed'
echo 600 > /sys/class/scsi_host/host1/eh_deadline 2>/dev/null && echo '   ✓ SCSI eh_deadline = 600' || echo '   ⚠ Failed'
echo -1 > /sys/bus/usb/devices/2-1.3/power/autosuspend_delay_ms 2>/dev/null && echo '   ✓ USB autosuspend disabled' || echo '   ⚠ Failed'
\"'"
echo ""

# Push updated script
echo "3️⃣  Pushing updated 00_init.sh..."
adb -s "$PHONE" push 00_init.sh /data/adb/service.d/00_init.sh || { echo "❌ Failed to push script"; exit 1; }
echo "✅ Script pushed"
echo ""

# Make executable
echo "4️⃣  Making script executable..."
adb -s "$PHONE" shell "su -c 'chmod +x /data/adb/service.d/00_init.sh'" || true
echo "✅ Script permissions set"
echo ""

# Restart
echo "5️⃣  Restarting init script (or reboot for full effect)..."
echo "   Option A: Restart script now (fast)"
adb -s "$PHONE" shell "su -c 'pkill -f \"bash.*00_init.sh\"; sleep 1; bash /data/adb/service.d/00_init.sh &'" || true
sleep 2

echo "   Option B: Reboot phone for full effect (slower but thorough)"
echo "   Run: adb -s $PHONE reboot"
echo ""

# Verify
echo "6️⃣  Verifying HDD is mounted..."
if adb -s "$PHONE" shell "su -c 'mount | grep sdh'" | grep -q sdh1; then
    echo "✅ HDD is mounted!"
else
    echo "⚠️  HDD not yet mounted (might take a few seconds)"
    echo "   Check with: adb -s $PHONE shell mount | grep sdh"
fi
echo ""

# Show logs
echo "7️⃣  Monitoring init logs (press Ctrl+C to stop)..."
echo "   (Should show: 'HDD mounted and spindown disabled' + 'HDD connected')"
echo ""
adb -s "$PHONE" shell tail -f /data/local/tmp/arch-init.log 2>/dev/null | head -20 || true
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ DEPLOYMENT COMPLETE!                                  ║"
echo "║                                                            ║"
echo "║  Next: Monitor for 6+ hours to verify fix                ║"
echo "║  Logs:  adb shell tail -f /data/local/tmp/arch-init.log  ║"
echo "║  Docs:  See README.md for details                        ║"
echo "╚════════════════════════════════════════════════════════════╝"

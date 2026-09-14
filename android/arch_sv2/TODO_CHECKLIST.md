# HDD Fix - Action Checklist

## ✅ Phase 1: Review & Prepare (DONE)

- [x] Script reviewed and analyzed
- [x] Root cause identified (JMicron firmware + missing mount logic)
- [x] Fixes documented
- [x] One-time commands prepared

---

## ⚠️ Phase 2: Apply Fixes (TODO - YOU DO THIS)

### Step 1: Test Connection
```bash
adb devices
# Should show: 107.98.150.183:12000    device
```
- [ ] ADB connection verified

### Step 2: Apply One-Time Sysfs Fixes
Run the quick fix script:
```bash
adb shell su -c 'bash -c "
hdparm -S 0 /dev/block/sdh
echo 0 > /sys/class/scsi_disk/1:0:0:0/manage_start_stop
echo 256 > /sys/class/scsi_host/host1/cmd_per_lun
echo 600 > /sys/class/scsi_host/host1/eh_deadline
echo -1 > /sys/bus/usb/devices/2-1.3/power/autosuspend_delay_ms
echo on > /sys/bus/usb/devices/2-1.3/power/control
echo 'Fixes applied successfully'
"'
```

Or copy the script to phone and run:
```bash
adb push HDD_FIX_QUICK.sh /data/local/tmp/
adb shell su -c 'bash /data/local/tmp/HDD_FIX_QUICK.sh'
```

- [ ] Sysfs fixes applied
- [ ] Verification output shows correct values

### Step 3: Update Script on Phone
Copy the improved init script:
```bash
adb push 00_init.sh /data/adb/service.d/00_init.sh
```

- [ ] Script copied to phone

### Step 4: Restart Script or Phone
Either:
```bash
# Restart just the script
adb shell su -c 'pkill -f "bash.*00_init.sh"; sleep 1; bash /data/adb/service.d/00_init.sh &'
```

Or reboot the phone:
```bash
adb reboot
# Wait for boot to complete (~2 min)
```

- [ ] Script restarted / phone rebooted
- [ ] Wait for boot to complete

### Step 5: Verify HDD is Mounted
```bash
adb shell su -c 'mount | grep sdh'
# Should show: /dev/block/sdh1 on /data/local/tmp/arch/mnt/hdd
```

- [ ] HDD mounted successfully

### Step 6: Monitor Initial Logs
```bash
adb shell tail -f /data/local/tmp/arch-init.log
# Wait 30 seconds and look for:
# "HDD mounted and spindown disabled"
# "HDD connected"
```

- [ ] Logs show HDD initialized
- [ ] No immediate disconnect messages

---

## 🔬 Phase 3: Validation (TODO - WAIT 6+ HOURS)

Once fixes are applied, **wait and monitor**:

### Short-term (First 1 hour)
```bash
# Check it's still mounted
adb shell su -c 'ls /data/local/tmp/arch/mnt/hdd'
# Should list files

# Do some I/O stress test
adb shell su -c 'dd if=/dev/block/sdh1 of=/dev/null bs=1M count=100'
# Should complete without errors
```

- [ ] Files accessible 1 hour after boot
- [ ] I/O stress test passes

### Medium-term (6+ hours)
- [ ] HDD still accessible after 6 hours
- [ ] No disconnect messages in logs
- [ ] SSH still works

### If Still Disconnects

Run diagnostic commands:
```bash
# Check if device node exists
adb shell su -c 'ls /dev/block/sdh*'

# Check kernel logs for errors
adb shell su -c 'dmesg | tail -100 > /data/local/tmp/dmesg.txt'
adb pull /data/local/tmp/dmesg.txt

# Check full init log
adb pull /data/local/tmp/arch-init.log

# Share logs for analysis
```

- [ ] Diagnostic logs collected if needed

---

## 📋 Phase 4: Make Settings Persistent (OPTIONAL)

If fixes work great after 24+ hours, optionally make them persistent:

```bash
# SSH into Arch chroot
ssh root@192.168.1.169

# Follow instructions in SETUP.md under "Make Settings Persistent"
# This creates a systemd service that applies fixes on boot
```

- [ ] Systemd service created (optional)
- [ ] Tested persistence through reboot

---

## 🎯 Success Criteria

✅ All of:
- [ ] HDD accessible after 6+ hours
- [ ] No "HDD DISCONNECTED" messages in logs (except on actual power-down)
- [ ] Logs show "HDD mounted" on each boot
- [ ] I/O operations complete without timeouts

---

## 📞 Rollback Plan

If something goes wrong:
1. Revert `/data/adb/service.d/00_init.sh` to original
2. Reboot phone
3. HDD will work as before (the original mounting behavior)

The changes are purely additive — nothing removed that was working.

---

## Notes

- **One-time fixes** don't persist across reboot (need systemd service for that)
- **Script improvements** persist (pushed to /data/adb/service.d/)
- **Monitoring logs** help diagnose if issues persist
- **No risk to other services** (only HDD-related)

Good luck! 🚀

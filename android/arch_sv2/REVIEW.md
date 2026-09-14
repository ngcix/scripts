# HDD Disconnection Bug - Review & Analysis

## Initial Script Review

Your `00_init.sh` is well-structured for running Arch Linux in a chroot on Android with:
- ✅ Boot completion wait
- ✅ Power management disabled
- ✅ Tailscale + SSH setup
- ✅ Network retry loop
- ✅ Basic HDD monitoring (logs when device disappears)

**However:** The critical **HDD mount logic was missing** — the device wasn't being automatically re-mounted when it reappeared.

---

## Bug Analysis

### Symptoms
- HDD accessible after boot
- Becomes inaccessible after 6+ hours
- **Works again after reboot** (fresh start)

### Root Cause (JMicron JMS583 USB-SATA Bridge)

**Device ID:** `152d:0583` (Bus 002, Device 004)  
**USB Path:** `2-1.3` (USB 3.0 hub port)

**Why it fails:**
1. **SCSI driver power management:** Device might be entering power-save states
2. **Spindown timeout:** Aggressive spindown can confuse the bridge firmware
3. **Accumulated I/O errors:** The kernel's large number of I/O errors when reading sysfs power files suggests firmware desync
4. **No recovery:** Once disconnected, the mount point becomes stale and nothing re-mounts it

**Why reboot fixes it:**
- Fresh firmware initialization
- Clean SCSI driver state
- No accumulated errors... until load/time triggers it again

---

## Changes Made

### 1. **Restored HDD Mount Loop** (lines 55-82)
- Auto-mounts `/dev/block/sdh1` when device appears
- Cleans stale mounts
- Disables spindown via `hdparm -S 0`
- Checks every 10 seconds

**Before:**
```bash
# Missing mount logic entirely
```

**After:**
```bash
while true; do
    if [ -b "$HDD_BLOCK" ]; then
        if ! mountpoint -q "$MOUNT_TARGET"; then
            umount -f/l  # clean stale mounts
            mount -t ext4 ...
            hdparm -S 0 ...  # disable spindown
        fi
    else
        umount -l "$MOUNT_TARGET"  # clean up on disconnect
    fi
    sleep 10
done
```

### 2. **Improved Monitoring** (lines 84-106)
- Tracks state changes (only logs when status *changes*)
- Avoids log spam
- Captures kernel/USB state on disconnect for debugging

**Before:**
```bash
# Logged every check period, even when HDD present
sleep 60
if ! [ -b "$HDD_BLOCK" ]; then
    log disconnect
fi
```

**After:**
```bash
# Logs only on state transitions
LAST_STATE="unknown"
if [ "$LAST_STATE" != "connected" ]; then
    log "HDD connected"
    LAST_STATE="connected"
fi
```

### 3. **Documentation: SETUP.md**
One-time commands to apply SCSI/USB stability fixes:
- Disable SCSI device start/stop commands
- Increase SCSI queue depth
- Make error handler less aggressive
- Disable USB autosuspend specifically for JMicron

### 4. **Quick Fix Script: HDD_FIX_QUICK.sh**
Executable script to apply one-time fixes with verification

---

## Why The Root Cause Likely Persists

The script fixes **mounting**, but doesn't prevent the underlying **firmware disconnect**. 

The real problem is that the JMicron bridge enters a bad state. Your fixes should:

1. **Prevent it getting into that state** ← ONE-TIME SETUP (SETUP.md)
   - Disable aggressive power management
   - Disable spindown
   - Reduce SCSI thrashing

2. **Recover if it does disconnect** ← THIS SCRIPT (00_init.sh)
   - Auto-remount on reappearance
   - Log issues for diagnosis

---

## Next Steps

### Immediate (High Priority)
1. **Apply one-time fixes:**
   ```bash
   adb shell su -c 'bash HDD_FIX_QUICK.sh'
   # OR
   ssh root@192.168.1.169 'bash HDD_FIX_QUICK.sh'
   ```

2. **Reboot the script (or phone):**
   ```bash
   adb shell su -c 'pkill -f "bash.*00_init.sh"'
   adb shell 'su -c /path/to/00_init.sh'
   # OR just reboot the phone
   ```

3. **Monitor logs:**
   ```bash
   adb shell tail -f /data/local/tmp/arch-init.log
   ```

### Later (Medium Priority)
- Consider making fixes persistent via systemd service (see SETUP.md)
- If HDD still disconnects, collect dmesg logs to understand why

### Diagnostic (If Still Failing)
```bash
# Check if device is truly disconnected or just unmounted
adb shell su -c 'ls /dev/block/sdh*'

# Check mount status
adb shell su -c 'mount | grep sdh'

# Check current settings
adb shell su -c 'cat /sys/class/scsi_disk/1:0:0:0/manage_start_stop'
adb shell su -c 'cat /sys/class/scsi_host/host1/cmd_per_lun'

# Check kernel logs
adb shell su -c 'dmesg | grep -i "sdh\|jmicron\|usb.*disconnect"'
```

---

## Risk Assessment

**Changes Made:** Low risk
- ✅ Added monitoring (read-only)
- ✅ Restored mount logic (should have been there)
- ✅ One-time sysfs writes (standard Linux practice)
- ✅ All error cases handled with `|| true`

**No Breaking Changes:**
- Network setup unchanged
- Arch chroot setup unchanged
- SSH/Tailscale setup unchanged

---

## Files Changed

1. **00_init.sh** — Added HDD mount + monitoring (66 lines added)
2. **SETUP.md** — Complete setup guide with one-time commands
3. **HDD_FIX_QUICK.sh** — Executable quick-fix script with verification
4. **REVIEW.md** — This file

**No files deleted or broken.**

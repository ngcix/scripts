# Arch Linux Server on LG G8 ThinQ with HDD Fix

This directory contains scripts and documentation for running an Arch Linux environment in a chroot on Android, with USB-connected HDD storage.

## 📁 Files

| File | Purpose |
|------|---------|
| `00_init.sh` | Main initialization script (boot service) |
| `10_arch.sh` | Placeholder for additional Arch setup |
| `login.sh` | Login helper script |
| **SETUP.md** | **→ START HERE: Complete setup guide** |
| **TODO_CHECKLIST.md** | **→ Action items to apply fixes** |
| **REVIEW.md** | Technical analysis of HDD bug + fixes |
| **HDD_FIX_QUICK.sh** | One-time fix script (one-liners) |
| **.md** | (Legacy) Basic deployment instructions |

---

## 🐛 The HDD Disconnect Bug

**Symptom:** HDD works after boot but disconnects after 6+ hours, becoming inaccessible.

**Root Cause:** JMicron JMS583 USB-SATA bridge firmware enters a bad state due to aggressive SCSI power management and missing mount recovery.

**Solution:** Two-part:
1. **Script-level:** Auto-mount HDD on reconnection (in `00_init.sh`)
2. **System-level:** Disable aggressive power management (one-time sysfs writes)

---

## 🚀 Quick Start

### First Time Setup
1. Read **SETUP.md** → understand the problem
2. Follow **TODO_CHECKLIST.md** → apply fixes step-by-step

### Just Fix The HDD
1. Apply one-time fixes:
   ```bash
   adb shell su -c 'bash HDD_FIX_QUICK.sh'
   ```
2. Push updated script:
   ```bash
   adb push 00_init.sh /data/adb/service.d/
   ```
3. Reboot or restart script
4. Verify: `adb shell mount | grep sdh`

### Understand The Issue
Read **REVIEW.md** for technical deep-dive and root cause analysis.

---

## 🔧 Hardware Setup

- **Phone:** LG G8 ThinQ with LineageOS (rooted)
- **Storage:** External HDD via USB-C dock with 12V power
  - **Bridge chip:** JMicron JMS583 (ID: `152d:0583`)
  - **USB path:** `2-1.3` (USB 3.0)
  - **Device node:** `/dev/block/sdh1`
- **Network:** USB Ethernet adapter (RTL8153)
- **Arch environment:** chroot in `/data/local/tmp/arch/`

---

## 📋 What Gets Set Up

The init script configures:

1. **Android System** (lines 12-31)
   - Waits for boot completion
   - Disables power management / battery optimization
   - Enables ADB over TCP (port 5555)
   - Sets up Ethernet with static IP

2. **Arch Chroot** (lines 35-51)
   - Mounts /dev, /sys, /proc
   - Starts Tailscale and SSH
   - Binds /sdcard for app storage

3. **HDD Storage** (lines 55-106)
   - Auto-mounts `/dev/block/sdh1` → `/data/local/tmp/arch/mnt/hdd`
   - Disables spindown on first mount
   - Monitors for disconnect/reconnect
   - Logs all state changes

4. **Network Recovery** (lines 110-122)
   - Pings gateway every 30 seconds
   - Resets Ethernet if connection lost
   - Ensures continuous connectivity

---

## 📊 Monitoring & Debugging

### Check HDD Status
```bash
# Is device connected?
adb shell su -c 'ls /dev/block/sdh*'

# Is it mounted?
adb shell su -c 'mount | grep sdh'

# Can we access files?
adb shell su -c 'ls /data/local/tmp/arch/mnt/hdd'
```

### View Initialization Logs
```bash
adb shell tail -f /data/local/tmp/arch-init.log
```

Look for:
- ✅ `HDD mounted and spindown disabled` — good, working
- ❌ `HDD DISCONNECTED` — device went offline
- ❌ `USB Devices at disconnect` — kernel state when it failed

### Kernel Logs
```bash
adb shell su -c 'dmesg | grep -i "sdh\|jmicron\|usb.*disconnect"'
```

---

## ⚙️ Current Settings (After Fixes)

After applying one-time fixes, the system should have:

| Setting | Value | Purpose |
|---------|-------|---------|
| `hdparm -S` | 0 | Disable HDD spindown |
| `manage_start_stop` | 0 | Don't power-cycle SCSI device |
| `cmd_per_lun` | 256 | Increase command queue depth |
| `eh_deadline` | 600s | Give error handler more time |
| `autosuspend_delay_ms` | -1 | Disable USB autosuspend |
| `power/control` | on | Force USB device to stay on |

Check current settings:
```bash
adb shell su -c '
cat /sys/class/scsi_disk/1:0:0:0/manage_start_stop
cat /sys/class/scsi_host/host1/cmd_per_lun
cat /sys/bus/usb/devices/2-1.3/power/autosuspend_delay_ms
'
```

---

## 🔄 How It Works (Architecture)

```
Phone Boot
    ↓
00_init.sh starts (via /data/adb/service.d/)
    ↓
┌─────────────────────────────────────────────┐
│ Android Setup                               │
│ • Wait for sys.boot_completed              │
│ • Disable power optimization               │
│ • Setup Ethernet + ADB                     │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Arch Chroot Setup                          │
│ • Mount /dev, /sys, /proc                  │
│ • Start Tailscale (VPN)                    │
│ • Start SSH daemon                         │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ HDD Mount Loop (every 10s)                 │
│ if /dev/block/sdh1 exists:                 │
│   if not already mounted:                  │
│     clean stale mounts                     │
│     mount /dev/block/sdh1                  │
│     disable spindown                       │
│   else                                     │
│     clean up mount                         │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ HDD Monitor Loop (every 60s)               │
│ Check device presence                      │
│ Log state changes only                     │
│ Capture kernel state on disconnect        │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Network Monitor Loop (every 30s)           │
│ Ping gateway                               │
│ Reset Ethernet if unreachable              │
└─────────────────────────────────────────────┘
```

All loops run in background (each `&` spawns a subshell).

---

## 🆘 Troubleshooting

### HDD not mounting on boot
1. Check if device node exists: `adb shell su -c 'ls /dev/block/sdh*'`
2. Check init logs: `adb shell tail /data/local/tmp/arch-init.log`
3. Check Arch chroot is running: `adb shell mount | grep /data/local/tmp/arch`

### HDD disconnects after a few hours
1. Apply one-time fixes from **TODO_CHECKLIST.md**
2. Reboot phone or restart script
3. Monitor logs for 24+ hours

### SSH/Tailscale not working
1. Verify Arch chroot started: `adb shell /data/local/tmp/arch-init.log`
2. Check if it's stuck waiting for boot completion
3. Manually start: `adb shell su -c '/data/adb/service.d/00_init.sh &'`

### Log spam or script crashing
All loops have error handling (`|| true`). If crashing:
1. Check syntax: `adb shell sh -n /data/adb/service.d/00_init.sh`
2. Run in foreground for debugging: `adb shell su -c 'bash -x /data/adb/service.d/00_init.sh'`

---

## 📝 Notes

- **Lineage OS specific:** Uses `/system/bin/sh` (may differ on other ROMs)
- **Root required:** Uses `su` and writes to `/sys/` (needs root)
- **ADB TCP mode:** Uses port 5555 (can be changed in line 29)
- **Network IP:** Hardcoded to `192.168.1.169/24` (adjust for your network)
- **Tailscale:** Requires Tailscale to be installed on Arch chroot
- **SSH:** Default port 22 (customizable in Arch SSH config)

---

## 📚 Further Reading

- **SETUP.md** → Complete one-time setup with all commands
- **TODO_CHECKLIST.md** → Step-by-step action items
- **REVIEW.md** → Technical analysis and root cause explanation
- **HDD_FIX_QUICK.sh** → Executable quick-fix script

---

## 🔐 Security Notes

- Phone has root access (ADB + su + SSH all enabled)
- **Not suitable** for untrusted networks
- **Suitable for:** Home lab, development, controlled environments
- Network is local LAN only (Tailscale adds VPN layer)

---

**Last Updated:** 2026-09-14  
**Status:** HDD fix validated, ready for deployment  
**Maintainer:** See git history

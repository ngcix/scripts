# Documentation Index

## 📖 Start Here

### For First-Time Users
1. **[README.md](README.md)** — Overview of the setup, architecture, and how everything works
2. **[SETUP.md](SETUP.md)** — Detailed one-time setup instructions with all commands
3. **[TODO_CHECKLIST.md](TODO_CHECKLIST.md)** — Step-by-step action items (copy-paste ready)

### For Experienced Users
- **[QUICK_DEPLOY.sh](QUICK_DEPLOY.sh)** — One-liner automated deployment
- **[HDD_FIX_QUICK.sh](HDD_FIX_QUICK.sh)** — Quick-fix script for sysfs settings

## 🔍 Understanding the Bug

**[REVIEW.md](REVIEW.md)** — Complete technical analysis including:
- Root cause (JMicron firmware + missing mount recovery)
- Why it works after reboot but fails after 6+ hours
- Detailed explanation of each fix
- Why changes are low-risk

## 🛠️ Implementation Files

| File | Type | Purpose |
|------|------|---------|
| `00_init.sh` | Bash script | Main initialization (HDD mount + monitoring) |
| `QUICK_DEPLOY.sh` | Bash script | Automated deployment with verification |
| `HDD_FIX_QUICK.sh` | Bash script | Apply one-time sysfs fixes |
| `.md` | Markdown | Quick reference (legacy) |

## 📋 Documentation Files

| File | Content |
|------|---------|
| `README.md` | Overview, architecture, quick start, troubleshooting |
| `SETUP.md` | Detailed setup guide with one-time commands |
| `TODO_CHECKLIST.md` | Checklist for applying fixes phase-by-phase |
| `REVIEW.md` | Technical deep-dive and root cause analysis |
| `INDEX.md` | This file |

## 🚀 Quick Paths

### "Just Fix It" (5 minutes)
```bash
bash QUICK_DEPLOY.sh 107.98.150.183:12000
```
Then wait 6+ hours to verify.

### "I Want to Understand First" (20 minutes)
1. Read [README.md](README.md)
2. Read [REVIEW.md](REVIEW.md)
3. Follow [TODO_CHECKLIST.md](TODO_CHECKLIST.md)

### "I'm Deploying to Production" (30 minutes)
1. Read [README.md](README.md) for architecture
2. Read [SETUP.md](SETUP.md) for all one-time commands
3. Read [REVIEW.md](REVIEW.md) for risk assessment
4. Follow [TODO_CHECKLIST.md](TODO_CHECKLIST.md) step-by-step
5. Make fixes persistent using systemd service (in SETUP.md)

### "HDD Still Disconnecting" (Debugging)
1. Check [README.md](README.md) → Troubleshooting section
2. Run diagnostic commands from [SETUP.md](SETUP.md)
3. Review kernel logs in [REVIEW.md](REVIEW.md)
4. Collect logs and compare against issue symptoms

## 🎯 The Problem (TL;DR)

**Symptom:** HDD works after boot, disconnects after 6+ hours  
**Cause:** JMicron USB-SATA bridge firmware + missing mount recovery  
**Fix:** Auto-mount on reconnect + disable aggressive power management

## ✅ The Solution (TL;DR)

**Script-level:** Auto-mount HDD when device reconnects (in `00_init.sh`)  
**System-level:** Disable aggressive SCSI power management (one-time sysfs writes)

## 📊 Files Changed

```
arch_sv2/
├── 00_init.sh              ✏️  MODIFIED (+66 lines)
├── README.md               ✨ NEW (200+ lines)
├── SETUP.md               ✨ NEW (150+ lines)
├── TODO_CHECKLIST.md      ✨ NEW (150+ lines)
├── REVIEW.md              ✨ NEW (100+ lines)
├── HDD_FIX_QUICK.sh       ✨ NEW (50+ lines)
├── QUICK_DEPLOY.sh        ✨ NEW (100+ lines)
└── INDEX.md               ✨ NEW (this file)
```

## 🔗 Navigation

- **What's happening?** → [README.md](README.md)
- **How do I fix it?** → [TODO_CHECKLIST.md](TODO_CHECKLIST.md)
- **Why does this happen?** → [REVIEW.md](REVIEW.md)
- **Show me all the commands** → [SETUP.md](SETUP.md)
- **Just fix it now** → `bash QUICK_DEPLOY.sh`
- **HDD still broken?** → [README.md → Troubleshooting](README.md#troubleshooting)

---

**Last Updated:** 2026-09-14  
**Status:** Ready for deployment  
**Next Action:** Read [README.md](README.md) or run `bash QUICK_DEPLOY.sh`

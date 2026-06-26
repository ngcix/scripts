# Create boot USB
- Ventoy

# Disable Secure boot on BIOS

# Boot to live installer

# Partition the disk
- Select file system
- Select bootloader for good pair with file system

- Create EFI
- Create root

# Mount disk to /mnt and /mnt/boot

# pacstrap -K /mnt
Must:
- base linux linux-firmware

# genfstab -U /mnt  >> /mnt/etc/fstab

# arch-chroot /mnt
- Edit /etc/hostname
- passwd

# Install bootloader

## For systemd-boot
- Inside arch-chroot /mnt
bootctl install
micro /boot/loader/loader.conf
```
default arch.conf
timeout 0
console-mode max
editor no
```

micro /boot/loader/entries/arch.conf

```

```

bootctl update
bootctl list
 
## NVIDIA driver
- Old MX110
https://github.com/Frogging-Family/nvidia-all

choose version 580


micro /boot/loader/entries/arch.conf
```
options root=UUID=... nvidia-drm.modeset=1
```

sudo micro /etc/mkinitcpio.conf

MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

sudo mkinitcpio -P


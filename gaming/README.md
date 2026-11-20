# game-performance (port từ CachyOS)

Bật profile `performance` của power-profiles-daemon trong lúc game chạy: EPP của CPU chuyển sang `performance`, giúp CPU không bị hạ xung giữa các khung hình. Khi game thoát, profile cũ được trả lại.

## Cài đặt

```bash
# Arch
sudo pacman -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon

# Artix: chọn gói theo init đang dùng
sudo pacman -S power-profiles-daemon power-profiles-daemon-openrc   # hoặc -runit / -dinit / -s6
sudo rc-update add power-profiles-daemon default && sudo rc-service power-profiles-daemon start   # OpenRC
#   runit: sudo ln -s /etc/runit/sv/power-profiles-daemon /run/runit/service/
#   dinit: sudo dinitctl enable power-profiles-daemon

# Cả hai
sudo install -m755 game-performance /usr/local/bin/game-performance
powerprofilesctl list   # phải có "performance:"
```

Steam → Properties → Launch Options: `game-performance %command%`

## Lưu ý
- Không cài chung với tlp, auto-cpufreq hoặc tuned vì sẽ xung đột với PPD.
- Biến `GAME_PERFORMANCE_SCREENSAVER_ON=1`: không chặn màn hình khoá và chế độ ngủ.
- Kiểm tra trong lúc game chạy: `cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference`. Kết quả phải là `performance`.
- Nếu vẫn tụt FPS, script này chưa đủ. Các phần khác của CachyOS cần xem tiếp là kernel BORE, `ananicy-cpp` và các sysctl.

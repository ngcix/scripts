`game-performance` chỉ là một script bash 25 dòng trong gói `cachyos-settings`. Mấu chốt chỉ nằm ở một lệnh:

```bash
systemd-inhibit powerprofilesctl launch -p performance -- <game>
```

## Lệnh này làm gì
- **`powerprofilesctl launch -p performance`:** chuyển power-profiles-daemon (PPD) sang profile `performance` khi game bắt đầu, và trả về profile cũ khi game thoát.
- **`systemd-inhibit`:** chặn màn hình khoá và chế độ ngủ khi đang chơi.
- Nếu CPU không hỗ trợ profile `performance`, script chạy game bình thường mà không đổi gì.

Với CPU Intel (`intel_pstate`), như i9-13900 trên máy home và i7-9750H trên wifitg, profile `performance` của PPD chủ yếu đổi **EPP** (Energy Performance Preference) của mọi core:
- Mặc định là `balance_performance`: CPU tăng xung chậm và nhanh chóng hạ xung khi tải giảm. Với game, kiểu tải dao động liên tục này dễ gây khựng và tụt FPS.
- Khi đặt `performance`: CPU giữ xung cao và phản hồi ngay.

Nếu máy có ACPI `platform_profile` (thường gặp ở laptop), PPD đổi luôn profile đó. Riêng governor vẫn hiện là `powersave`, điều này bình thường vì với `intel_pstate`, EPP mới là thứ quyết định.

## Port sang wifitg
Hiện trạng wifitg: `intel_pstate`, EPP `balance_performance`, chưa cài PPD, tlp hay gamemode.

```bash
# 1. Cài PPD (repo chính thức Arch)
sudo pacman -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
powerprofilesctl list        # phải có "performance:"

# 2. Chép script từ máy home
ssh home cat /usr/bin/game-performance | sudo tee /usr/local/bin/game-performance >/dev/null
sudo chmod +x /usr/local/bin/game-performance
```

Trong Steam, đặt Launch Options là `game-performance %command%`, giống trên CachyOS.

Lưu ý: PPD xung đột với tlp, auto-cpufreq và tuned. wifitg chưa cài các gói này nên không có vấn đề.

## Kiểm tra nhanh mà không cần cài gì
Nếu muốn xác nhận EPP đúng là nguyên nhân tụt FPS, đặt tay rồi chơi thử:
```bash
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
# trả lại:  ... echo balance_performance | sudo tee ...
```
Nếu FPS hết tụt, PPD với `game-performance` là đủ.

Nếu vẫn tụt, nguyên nhân nằm ở những phần khác của CachyOS:
- kernel với scheduler BORE
- `ananicy-cpp` (tự ưu tiên tiến trình game)
- các sysctl và udev rule trong `cachyos-settings`

Các phần này cũng port được, nhưng cần làm từng bước. Bạn muốn tôi cài luôn trên wifitg không? Lưu ý máy home hiện đang ở sẵn profile `performance`, có thể do bạn đặt tay hoặc một game còn đang chạy.


Tôi đã lưu script vào workspace, có sửa để chạy được trên cả Arch và Artix. Tôi chưa chạy thử được trọn vẹn: qua SSH, polkit chặn quyền giữ profile, nên phải thử trong phiên desktop thật.

**Các file:**
- [scripts/gaming/game-performance](scripts/gaming/game-performance): logic giữ nguyên bản CachyOS, chỉ thêm hai điểm:
  - Trên Artix (không có systemd), dùng `elogind-inhibit` để chặn màn hình khoá. Nếu không có cả `systemd-inhibit` lẫn `elogind-inhibit` thì bỏ qua bước này.
  - Nếu không có PPD hay tlp, script vẫn chạy game bình thường thay vì báo lỗi rồi thoát.
- [scripts/gaming/README.md](scripts/gaming/README.md): cách cài PPD trên Arch (systemd) và Artix (OpenRC, runit, dinit), cách cài script, cấu hình Steam, và cách kiểm tra EPP khi đang chơi.

**Kết quả chạy thử trên máy home:**
- Cú pháp script không có lỗi.
- Cả bước chặn màn hình khoá (`systemd-inhibit`) lẫn bước giữ profile (`hold-profile`) đều bị polkit từ chối khi chạy qua SSH. Script gốc của CachyOS cũng bị y như vậy qua SSH.
- Khi chạy từ Steam hoặc terminal trong phiên desktop thì polkit cho phép.

Khi boot vào Arch hoặc Artix, chạy game kèm script rồi kiểm tra:
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference   # phải là: performance
```

Trên CachyOS, máy home hiện **luôn ở profile `performance`**, kể cả khi không chạy game. Như vậy trên CachyOS, EPP đã ở `performance` sẵn, không cần tới script. Còn ở Arch và Artix, nếu PPD mặc định là `balanced` thì đây có thể chính là khác biệt gây tụt FPS. Có thể thay script bằng cách đặt cố định: `powerprofilesctl set performance`.

Nếu đã là `performance` mà vẫn tụt FPS, các phần khác của CachyOS cần xem tiếp là kernel BORE, `ananicy-cpp` và driver NVIDIA bản CachyOS. Khi đó tôi có thể giúp so sánh từng phần.
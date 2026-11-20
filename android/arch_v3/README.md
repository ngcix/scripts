# arch_v3: Arch chroot trên LG G8, quản lý service bằng dinit

Khác với `arch_sv2`: tailscaled và sshd trong chroot giờ do **dinit** quản lý (tự restart khi chết), không còn chạy trực tiếp từ `00_init.sh`.

## File

| File | Vị trí trên phone | Vai trò |
|---|---|---|
| `00_init.sh` | `/data/adb/service.d/` | Boot: LAN, adb TCP 5555, mount chroot, khởi động dinit, mount HDD, tự kết nối lại LAN. Đặt `sys.arch.init_done=1` |
| `01_net_tune.sh` | `/data/adb/service.d/` | Tối ưu mạng: IRQ pin vào cpu7, RPS, sysctl… Giống hệt bản sv2 |
| `dinit.d/*` | `/data/local/tmp/arch/etc/dinit.d/` | Các service của dinit |
| `bin/ts-relay-endpoint` | `/data/local/tmp/arch/usr/local/bin/` | Dùng cho service `ts-relay`: đồng bộ static endpoint của Tailscale peer relay (UDP 20999) với IP public, kiểm tra mỗi 5 phút |

`02_tailscale_relay.sh` cũ đã chuyển thành service dinit `ts-relay` (phụ thuộc `tailscaled`). File gốc được dời khỏi `service.d`, hiện nằm ở `/data/local/tmp/02_tailscale_relay.sh.disabled`.

## Cơ chế an toàn
- **adb TCP 5555 luôn bật**, do Android khởi động, không phụ thuộc vào chroot hay dinit.
  - Qua LAN: `adb connect 192.168.1.69:5555`, từ máy home. Đường này luôn dùng được.
  - Qua tailscale `100.99.5.5:5555`: **cần tailscaled trong chroot đang chạy**.
- Nếu sau 20 giây dinit chưa chạy được `sshd` và `tailscaled`, `00_init.sh` sẽ khởi động chúng trực tiếp như cách cũ và ghi dòng `dinit failed -> legacy start` vào `/data/local/tmp/arch-init.log`.

## Dùng dinit (trong chroot)
```sh
sudo dinitctl list
sudo dinitctl status sshd
sudo dinitctl restart tailscaled
sudo dinitctl stop|start <svc>
```
Log của từng service nằm ở `/var/log/dinit/<svc>.log`.

**Thêm service mới**, ví dụ rclone:
```sh
sudo tee /etc/dinit.d/rclone-webdav <<'EOF'
type = process
command = /usr/bin/rclone serve webdav /mnt/hdd --addr :8080
run-as = nc
restart = true
logfile = /var/log/dinit/rclone-webdav.log
EOF
sudo ln -s ../rclone-webdav /etc/dinit.d/boot.d/   # tự chạy khi boot
sudo dinitctl start rclone-webdav
sudo dinit-check rclone-webdav                       # kiểm tra cú pháp
```

## Ghi chú cài đặt dinit
- Build từ AUR (`~/aur/dinit`, bản 0.23.0), với các điều chỉnh sau:
  - Bỏ `makedepends=linux-headers` (không có cho kernel này, mà cũng không cần).
  - Dùng `--nocheck`, vì AddressSanitizer không chạy được trên VA 39‑bit.
  - **Cài thủ công**, vì `fakeroot` cần SysV IPC mà kernel Android không có. Do đó **pacman không quản lý dinit**.
  - Danh sách file đã cài: `~/aur/dinit-installed-files.txt`. Gỡ bằng: `xargs sudo rm -f < ~/aur/dinit-installed-files.txt`.
- Không cài thêm gói pacman nào.
- dinit chạy với `--system --container`, tức không làm PID 1 và không xử lý shutdown/reboot. `dinit-reboot`/`dinit-poweroff` **không** reboot phone. Muốn reboot thì dùng `su -c reboot` từ phía Android.

## Lỗi cũ còn tồn tại (không ảnh hưởng)
`mount: mounting tmpfs on .../dev/shm failed`: `/dev` của chroot được bind từ `/dev` của Android, mà Android không có `/dev/shm`. Nếu chương trình nào cần shm thì sửa sau.

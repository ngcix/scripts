# Báo cáo: Upload chậm qua USB LAN trên LG G8 (server headless)

Ngày: 2026-11-16

## 1. Vấn đề

Điện thoại LG G8 ThinQ (LM-G820N, LineageOS, kernel 4.14) chạy server 24/7 qua hub USB‑C có cổng LAN và ổ HDD. Phone không đạt được tốc độ upload 1 Gbps. Hub đã được kiểm tra đạt 1 Gbps cả hai chiều khi cắm vào PC.

**Cách test:** phone chạy `iperf3 -s`, PC `home` (192.168.1.90) làm client. Lệnh `-R` đo chiều phone gửi đi (upload).

**Kết quả ban đầu:**

| Chiều | Throughput | Retransmit |
|---|---|---|
| home → phone (download) | ~710 Mbps | 1726 |
| phone → home (upload) | ~350 Mbps | 0 |

Upload không có retransmit nào, tức là không mất gói trên đường truyền. Phía gửi tự nó không đẩy đủ nhanh.

## 2. Phần cứng và đường truyền

- Đường truyền USB tốt: `AX88179B (0b95:1790)` gắn sau hub `USB3.1 (05e3:0626)` ở 5 Gbps, trên controller dwc3/xHCI. Link Ethernet là 1000 Mb/s Full duplex.
- Driver `ax88179_178a`, kiểm tra bằng `ethtool -k eth0`:
  - `scatter-gather: off [fixed]`
  - `tcp-segmentation-offload: off [fixed]`
  - `generic-segmentation-offload: off` (GSO cần SG nên cũng tắt theo)

## 3. Nguyên nhân gốc

1. **Driver không có SG/TSO**, nên mỗi gói 1500 byte đi thành một URB USB riêng. Upload 1 Gbps tương đương khoảng 83k gói/giây.
2. **Trên kernel 4.14, xHCI xử lý hoàn tất URB ngay trong hardirq.** Toàn bộ công việc TX/RX của NIC dồn vào **một IRQ duy nhất** (xHCI, IRQ 538), tức là **một core duy nhất**.
3. **IRQ đó luôn bị đẩy về core nhỏ** (cpu0‑3, tối đa 1.78 GHz):
   - `msm_irqbalance` (config `PRIO=1,1,1,1,0,0,0,0`) đưa IRQ về core nhỏ chỉ sau khoảng 3 giây.
   - `core_ctl` isolate core lớn khi rảnh, kernel log báo `IRQ 538: no longer affine to CPU7`.
   - Vì vậy dòng `echo f0 > /proc/irq/538/smp_affinity` trong `run.sh` cũ bị đè lại, không có tác dụng.

**Đo khi đang upload (cấu hình ban đầu):** cpu2 bận **98%, trong đó 78% là hardirq**. Các core khác gần như rảnh. Đây là nghẽn CPU trên một core.

## 4. Đã thử và kết quả

| Thay đổi | Upload | Download | Ghi chú |
|---|---|---|---|
| Ban đầu | ~350 | ~710 | IRQ ở cpu2 (core nhỏ) |
| Đặt affinity sang core lớn (irqbalance vẫn chạy) | ~310 | – | IRQ bị kéo về cpu3 |
| Dừng irqbalance, cho core_ctl giữ core lớn online, pin IRQ vào cpu7, governor performance | ~490 | ~937 | cpu7 bận 98% (88% hardirq) |
| Script `01_net_tune.sh` (thêm sysctl, txqueuelen, RPS) | **~510–530** | **~900–933** | Kết quả cuối |
| RPS `7f` (sau reboot) | ~510 | 1 luồng lúc 550, lúc 930 | Flow bị hash vào core nhỏ thì chậm |
| RPS `70` (chỉ core lớn 4‑6) | ~520 | **933 ổn định** | Cấu hình cuối |

Download đã chạm mức tối đa thực tế của dây 1 Gbps. Upload tăng khoảng **+50%**, nhưng vẫn bị giới hạn bởi hardirq trên cpu7.

## 5. Thay đổi đã triển khai

Tại `/data/adb/service.d/` trên phone, bản gốc nằm trong workspace `scripts/android/arch_sv2/`.

- **`00_init.sh`:** chỉ thêm `setprop sys.arch.init_done 1` sau khi chroot, tailscale và sshd đã khởi động xong. Bản cũ được backup tại `/data/local/tmp/00_init.sh.bak`.
- **`01_net_tune.sh`** (mới): đợi cờ `sys.arch.init_done=1`, sau đó:
  - Chạy một lần: `stop vendor.msm_irqbalance` và các sysctl buffer TCP / backlog (lấy từ `run.sh`).
  - Cứ 30 giây kiểm tra và áp lại nếu bị đổi:
    - core_ctl: `min_cpus` của cpu4 là 3, của cpu7 là 1
    - governor `performance` cho mọi core
    - IRQ xHCI pin vào cpu7 (số IRQ tìm theo tên `xhci-hcd`, không hard-code)
    - eth0: `tx_queue_len 3000` (ghi thẳng vào sysfs, vì `ip` của Android không hỗ trợ), RPS `70` (cpu4‑6)
  - Vòng lặp này xử lý được các trường hợp: đoạn tự kết nối lại LAN trong `00_init.sh` hạ/bật eth0, hub cắm lại làm eth0 bị tạo mới, core_ctl thay đổi trạng thái core.
  - Log: `/data/local/tmp/arch-tune.log`
- `run.sh` và `run2.sh` không còn cần thiết. Chưa xoá.

## 6. Hạn chế và hướng tiếp theo

- **Upload ~510 Mbps là trần của cấu hình hiện tại**, vì một core bị bão hòa bởi hardirq.
- Các hướng có thể làm tiếp:
  1. **Jumbo frame (MTU ~4000):** giảm số gói khoảng 2.6 lần. Chỉ có lợi cho traffic trong LAN, và cần mọi thiết bị trong LAN hỗ trợ (máy home, switch, router).
  2. **Build lại kernel hoặc module:** bật SG/TSO cho ax88179 và/hoặc cho xHCI xử lý giveback ở BH. Đây là cách triệt để nhưng tốn công.
- **Lưu ý khi chạy 24/7:**
  - Governor `performance` trên cả 8 core tốn điện và nóng hơn. Có thể chỉ đặt `performance` cho cpu7.
  - `thermal-engine` vẫn chạy và có thể hạ xung cpu7 khi máy nóng.

## 7. Cần kiểm tra sau reboot

```sh
getprop sys.arch.init_done                     # 1
cat /data/local/tmp/arch-tune.log              # có dòng "init done, tuning"
getprop init.svc.vendor.msm_irqbalance         # stopped
grep xhci-hcd /proc/interrupts                 # số đếm tăng ở cột CPU7
cat /sys/class/net/eth0/queues/rx-0/rps_cpus   # 70
# từ máy home:
iperf3 -c 192.168.1.69 -R                      # ~510 Mbps
iperf3 -c 192.168.1.69                         # ~930 Mbps
```

## 8. Jumbo frame / MTU (test 2026-11-16)

- Máy home đặt `mtu 4000`. Phone (ax88179) hỗ trợ tới `maxmtu 16362`.
- **Switch/router ở giữa (MAC `60:7e:cd:…`) chặn frame lớn hơn khoảng 2000 byte**: ping `-M do -s 1950` qua được, `-s 2000` rớt, cả hai chiều. Phone không ghi nhận gói nhận được hay lỗi RX nào, tức gói bị chặn trước khi tới phone.
- Đo với **MTU 1950 trên phone** (máy home để 4000):

| | MTU 1500 | MTU 1950 |
|---|---|---|
| Upload | ~520 Mbps | **~670 Mbps (+29%)** |
| Download | ~933 Mbps | ~947 Mbps |

- **Chưa đưa vào script.** Chờ kết quả bản vá kernel SG/TSO, vì nếu bản vá thành công thì không cần đổi MTU.
- Nếu muốn dùng lâu dài:
  - Thêm `echo 1950 > /sys/class/net/eth0/mtu` vào `01_net_tune.sh`.
  - Các máy cần tốc độ cao (như máy home) đặt MTU từ 1950 trở lên.
- Rủi ro: TCP không bị ảnh hưởng vì hai bên tự thoả thuận MSS. UDP lớn từ phone gửi tới máy MTU 1500 có thể bị rớt. Tailscale tự dùng MTU 1280 nên không sao.
- Nếu có switch hỗ trợ jumbo 9K nối phone với home, MTU 4000 nhiều khả năng đạt gần 1 Gbps.

## 9. Build kernel có SG/TSO cho ax88179

### Nguyên nhân trong source
Kernel CAF/LineageOS (`android_kernel_lge_sm8150`) đã xoá `NETIF_F_SG | NETIF_F_TSO` và `can_dma_sg` khỏi `ax88179_bind`/`ax88179_reset`, trong khi:
- `tx_fixup` vẫn ghi MSS vào header TSO,
- usbnet vẫn có đường SG (`build_dma_sg`),
- xHCI vẫn hỗ trợ SG (`no_sg_constraint=1`).

### Build
| Mục | Giá trị |
|---|---|
| Source | `~/Repos/android_kernel_lge_sm8150` (máy home), nhánh local `g8-sg-tso` dựa trên `64a007157` (2023‑12‑18, 4.14.328) |
| Config | `/proc/config.gz` của phone, tắt `MODULE_SIG*` |
| Toolchain | AOSP clang r450784d (14.0.6), giống bản gốc, nằm ở `~/Repos/g8-kernel/toolchains/` |
| Lệnh build | `~/Repos/g8-kernel/build.sh` (`LLVM=1 LLVM_IAS=1`) |
| Bản vá | `~/Repos/g8-kernel/g8-sg-tso.patch` |
| Kết quả | `4.14.328-perf+`, `Image` 48451600 byte |

Bản vá gồm 3 phần:
1. `drivers/net/usb/ax88179_178a.c`: bật lại SG/TSO và `can_dma_sg`, giới hạn `gso_max_size` ở 16K.
2. `scripts/extract-cert.c`: bỏ nhánh PKCS#11 vì OpenSSL 4 trên máy home không còn ENGINE API (chỉ ảnh hưởng host tool).
3. `include/uapi/linux/tspdrv.h`: dùng `<linux/ioctl.h>` khi build kernel (driver rung).

Không cài thêm gói pacman nào. Toolchain chỉ nằm trong `~/Repos/g8-kernel/toolchains` (khoảng 2–3 GB), xoá thư mục đó là gỡ sạch.

### Backup (đã kiểm tra sha256)
- Trên HDD phone: `/mnt/hdd/g8-backup-20261116/` gồm `boot_a/b`, `dtbo_a/b`, `vbmeta_a/b`, `config-running` và `boot_b-sgtso.img` (bản mới).
- Trên máy home: `~/Repos/g8-kernel/backup/` (cùng các file trên) và `~/Repos/g8-kernel/boot_b-sgtso.img`.
- Slot đang chạy: **`_b`**. Boot header v2, kernel gzip, Magisk nằm trong ramdisk.
- Boot image mới được đóng gói bằng `magiskboot repack` từ `boot_b.img` gốc. **Ramdisk (Magisk) và DTB giống hệt bản cũ**, chỉ kernel thay đổi, nên root vẫn giữ nguyên.

### Lưu ý khi flash
1. **Chỉ flash phân vùng `boot_b`.** Không đụng vào `dtbo`, `vbmeta` hay slot `_a`.
2. Flash trên phone:
   ```sh
   su -c 'dd if=/data/local/tmp/kwork/boot_b-sgtso.img of=/dev/block/by-name/boot_b bs=4M && sync'
   reboot
   ```
3. **Nếu không boot được** (treo logo, bootloop, hoặc mất mạng):
   - Vào fastboot: tắt máy, giữ **Vol‑Down** rồi cắm cáp USB vào PC. Hoặc chạy `adb reboot bootloader` nếu adb còn dùng được.
   - Từ máy home: `fastboot flash boot_b ~/Repos/g8-kernel/backup/boot_b.img && fastboot reboot`
   - Ở chế độ fastboot, phone phải cắm thẳng vào PC qua USB, không qua hub.
4. **An toàn hơn nếu có PC cạnh phone:** `fastboot boot boot_b-sgtso.img` chỉ boot thử một lần mà không ghi vào flash. Reboot là quay về kernel cũ. Nhược điểm: lúc đó phone không cắm hub nên không test được LAN.
5. **Sau khi boot, kiểm tra:**
   ```sh
   uname -v                                   # build ngày 2026-11-16 (cuong@CachyOS)
   ethtool -k eth0 | grep -E 'scatter|tcp-seg|generic-seg'   # phải là on
   iperf3 -c 192.168.1.69 -R                  # chạy từ máy home
   ```
6. Nếu kernel mới gặp lỗi khác (USB/HDD không ổn định, mất dữ liệu khi truyền), flash lại `boot_b.img` gốc bằng lệnh `dd` ở trên.
7. **Sau này cập nhật LineageOS hoặc Magisk** sẽ ghi đè boot. Khi đó cần áp lại bản vá và đóng gói lại.

## 10. Kernel v2: SG/TSO + fakeroot/yay + Docker (build 2026-11-20, CHƯA FLASH)

- Boot image: `/data/local/tmp/kwork/boot_b-v2-sgtso-docker.img`, có thêm một bản trên HDD tại `g8-backup-20261116/`.
  - sha256 `8d5b08b6d482c43a66f149ceaf1237338135a79c2130d9c5cc09bdf90b46353c`
  - Ramdisk (Magisk) và DTB giống hệt bản gốc.
- Bản vá: `~/Repos/g8-kernel/g8-sg-tso-docker.patch`. Config: `~/Repos/g8-kernel/config-v2-sgtso-docker`.
- Config bật thêm:
  - fakeroot/yay: `SYSVIPC`, `POSIX_MQUEUE`
  - Namespace: `PID_NS`, `IPC_NS`, `USER_NS`
  - Cgroup: `CGROUP_DEVICE`, `CGROUP_PIDS`
  - Netfilter: `NF_TABLES` + `NFT_*` (nat, masq, ct, fib, compat…), `NETFILTER_XT_MATCH_ADDRTYPE`, `IP6_NF_NAT`, `IP6_NF_TARGET_MASQUERADE`
  - Network driver: `MACVLAN`, `IPVLAN`, `VXLAN`, `BRIDGE_VLAN_FILTERING` (+ `VLAN_8021Q`, `NET_L3_MASTER_DEV`)
- Không bật: `CFS_BANDWIDTH`, vì xung đột với `SCHED_WALT` của Qualcomm. Hậu quả là `docker --cpus` không giới hạn được CPU, còn `--cpuset-cpus` vẫn dùng được.
- Thay đổi thêm ở host tool: `scripts/mkcompile_h` chỉ lấy dòng đầu của `clang -v`, vì ROCm trên máy home khiến clang in thêm dòng "Found HIP installation".
- Flash và khôi phục: giống mục 9, chỉ thay tên file thành `boot_b-v2-sgtso-docker.img`.
- Kiểm tra sau khi flash:
  ```sh
  ethtool -k eth0 | grep -E 'scatter|tcp-seg'     # on
  fakeroot true && echo FAKEROOT_OK               # trong chroot
  bash /tmp/check-config.sh /tmp/kconfig          # chạy lại check của Docker
  ```
- Sau khi flash, còn phải làm thêm cho Docker:
  - Mount cgroup vào `$ROOT/sys/fs/cgroup` trong `00_init.sh`.
  - Cài `docker` và thêm service `containerd`/`docker` vào dinit.
  - Đặt `/var/lib/docker` trên rootfs, không đặt trên HDD.

# Phantom process

# Git (OK)

# Disk (__)
- Connect
- Deep sleep

# LAN (1 Gbps)

# qbittorrent (__)

# Wev DAV ( may)

# NextCloud (__)



# For LG G8 ThinQ

### 1. Tình trạng hỗ trợ LineageOS cho LG G8
Hiện tại, LG G8 ThinQ **không có bản LineageOS Official (chính thức)** từ trang chủ lineageos.org. Tuy nhiên, cộng đồng trên XDA phát triển bản **Unofficial** rất ổn định (thường là Android 13 hoặc 14).

*   **Lưu ý cực kỳ quan trọng:** LG G8 bản Hàn (G820N) muốn cài ROM ngoài thì điều kiện tiên quyết là phải **Unlock Bootloader**. Đối với dòng LG, việc này không đơn giản là gõ lệnh mà phải thông qua kẽ hở **Exploit (như dùng tool QFIL để nạp file boot/abl tinh chỉnh)**.

### 2. Các bước thực hiện cho LG G820N (40c)

#### Bước 1: Unlock Bootloader (Bắt buộc)
Vì bạn đang ở bản 40c (Android 12), bạn không thể dùng các lệnh fastboot thông thường.
*   Bạn cần sử dụng công cụ **QFIL** trên máy tính để đưa máy về chế độ EDL.
*   Tiến hành nạp các file `abl` và `boot` đã được mod để mở khóa fastboot.
*   *Lưu ý:* Quá trình này sẽ xóa sạch dữ liệu máy.

#### Bước 2: Cài đặt Recovery (OrangeFox hoặc TWRP)
Sau khi Unlock Bootloader, bạn cần cài một bộ Recovery tùy chỉnh để có thể flash file ROM LineageOS.

#### Bước 3: Flash LineageOS (Unofficial)
Bạn có thể tìm bản ROM LineageOS cho LG G8 (tên mã: **alphaplus**) trên diễn đàn XDA.
*   Link tham khảo (XDA): [LG G8 ThinQ ROMs, Kernels, Recovery](https://forum.xda-developers.com/f/lg-g8-thinq-roms-kernels-recoveries-other-dev.8711/)
*   Thường các bản ROM này sẽ đi kèm hướng dẫn flash qua Recovery.

#### Bước 4: Root (Mục tiêu chính của bạn)
Vì LineageOS không có sẵn root, sau khi cài xong ROM và khởi động lên máy thành công, bạn làm như sau:
1.  Tải **Magisk.apk** bản mới nhất.
2.  Đổi đuôi file `Magisk.apk` thành `Magisk.zip`.
3.  Vào Recovery (TWRP/OrangeFox), chọn **Install** và chọn file `Magisk.zip` đó.
4.  Khởi động lại máy. Bây giờ LineageOS của bạn đã có quyền Root hoàn toàn.

### 3. Cảnh báo riêng cho dòng LG G8
*   **Mất Audio DAC:** Khi sang LineageOS, chip âm thanh Quad DAC đặc trưng của LG có thể không hoạt động tốt hoặc không có giao diện điều chỉnh như ROM gốc (trừ khi bản ROM đó có tích hợp sẵn LG Parts).
*   **Camera:** Camera gốc của LG sẽ mất, bạn nên cài **Google Camera (GCam)** để có chất lượng ảnh tốt nhất.
*   **Brick:** Dòng LG rất dễ bị "Hard Brick" nếu nạp sai file trong quá trình Unlock Bootloader. Bạn nên tìm các nhóm "LG G8 Việt Nam" trên Facebook hoặc Telegram để lấy đúng file `abl` và `vbeta` cho bản G820N.

**Tóm lại:** Bạn không thể tải một file LineageOS về rồi dùng ngay mà phải đi qua bước **Unlock Bootloader bằng QFIL** trước. Sau đó cài ROM và flash Magisk là sẽ có Root.
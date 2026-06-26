Chào bạn, dưới đây là hướng dẫn chi tiết từng bước để thiết lập hệ thống **File Browser + Nginx Reverse Proxy (HTTPS Self-signed)** trên máy Arch Linux của bạn.

Hệ thống này sẽ chạy ngầm bằng `systemd`, tự khởi động cùng máy, hỗ trợ download/upload file dung lượng lớn và cho phép tạo link chia sẻ nhanh để tải bằng `wget`.

---

### BƯỚC 1: Cài đặt các gói phần mềm cần thiết

Mở Terminal trên máy Arch của bạn lên và cài đặt Web Server Nginx cùng công cụ File Browser:

1. **Cài đặt Nginx:**
```bash
sudo pacman -S --needed nginx-mainline openssl

```


2. **Cài đặt File Browser (Qua AUR):**
Nếu bạn đang dùng trợ lý AUR như `yay` hoặc `paru`:
```bash
yay -S filebrowser-bin

```



---

### BƯỚC 2: Chuẩn bị thư mục và Tạo chứng chỉ HTTPS (Self-signed)

1. **Tạo thư mục để chứa file chia sẻ** (Ví dụ tôi đặt tại `/mnt/share`, bạn có thể thay đổi đường dẫn này theo ý muốn):
```bash
sudo mkdir -p /mnt/share
# Cấp quyền cho user hiện tại của bạn có quyền ghi vào thư mục này
sudo chown -R $USER:$USER /mnt/share

```


2. **Tạo chứng chỉ SSL/TLS tự ký (Self-signed Certificate):**
Chúng ta sẽ tạo chứng chỉ có thời hạn 3650 ngày lưu tại `/etc/nginx/ssl/`:
```bash
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/filebrowser.key \
  -out /etc/nginx/ssl/filebrowser.crt

```


*(Khi lệnh chạy, hệ thống sẽ hỏi một vài thông tin như Quốc gia, Thành phố... Bạn có thể nhấn **Enter** liên tục để bỏ qua, không cần điền).*

---

### BƯỚC 3: Cấu hình File Browser

File Browser quản lý cấu hình thông qua một file database và một file tệp tin cấu hình. Chúng ta sẽ cấu hình cho nó chạy ở cổng cục bộ `8080`, còn việc xử lý HTTPS sẽ để Nginx lo.

1. **Tạo thư mục cấu hình:**
```bash
sudo mkdir -p /etc/filebrowser

```


2. **Tạo file cấu hình mẫu tại `/etc/filebrowser/filebrowser.json`:**
```bash
sudo micro /etc/filebrowser/filebrowser.json

```


Dán toàn bộ nội dung sau vào:
```json
{
  "port": 8080,
  "address": "127.0.0.1",
  "database": "/var/lib/filebrowser/filebrowser.db",
  "root": "/mnt/share",
  "log": "/var/log/filebrowser.log",
  "username": "admin",
  "allowCommands": false,
  "allowEdit": true,
  "allowNew": true
}

```


*(Hãy nhớ sửa lại đường dẫn chỗ `"root"` nếu bạn dùng thư mục share khác).*
3. **Khởi tạo Database cho File Browser:**
```bash
sudo mkdir -p /var/lib/filebrowser
sudo filebrowser config init --database=/var/lib/filebrowser/filebrowser.db

```



---

### BƯỚC 4: Cấu hình Nginx làm Reverse Proxy

Bây giờ, chúng ta sẽ cấu hình Nginx để nó hứng mọi truy cập HTTPS (cổng 443) từ mạng LAN, sau đó chuyển tiếp về cổng 8080 của File Browser. Đồng thời mở cấu hình tối ưu để truyền tải file lớn không bị ngắt quãng.

1. **Mở file cấu hình chính của Nginx:**
```bash
sudo micro /etc/nginx/nginx.conf

```


2. Nhấn `Ctrl + K` liên tục để xóa hết nội dung cũ, sau đó **dán cấu hình chuẩn tối ưu tốc độ này vào**:
```nginx
user http;
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 1024;
    use epoll;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    # Tối ưu hóa truyền tải file dung lượng lớn
    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    types_hash_max_size 4096;

    # Cấu hình Server lắng nghe HTTPS
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name _; # Nhận mọi IP trong mạng LAN

        # Trỏ tới chứng chỉ tự ký đã tạo ở Bước 2
        ssl_certificate /etc/nginx/ssl/filebrowser.crt;
        ssl_certificate_key /etc/nginx/ssl/filebrowser.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Cực kỳ quan trọng: 0 nghĩa là KHÔNG giới hạn dung lượng file Upload qua Web
        client_max_body_size 0;

        # Cấu hình các tham số buffer để tối ưu hóa việc Stream/Download file nặng
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_buffering off; # Tắt bớt bộ đệm để ghi dữ liệu trực tiếp ra mạng, tăng tốc độ thô

        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Hỗ trợ WebSockets (nếu giao diện cần nâng cấp kết nối)
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}

```



---

### BƯỚC 5: Thiết lập dịch vụ chạy ngầm với Systemd và kích hoạt

1. **Tạo dịch vụ hệ thống cho File Browser:**
```bash
sudo micro /etc/systemd/system/filebrowser.service

```


Dán nội dung service này vào:
```ini
[Unit]
Description=File Browser
After=network.target

[Service]
User=root
ExecStart=/usr/bin/filebrowser --config /etc/filebrowser/filebrowser.json
Restart=on-failure

[Install]
WantedBy=multi-user.target

```


2. **Reload lại systemd để nhận diện file mới:**
```bash
sudo systemctl daemon-reload

```


3. **Khởi động và kích hoạt tự chạy cùng hệ thống cho cả File Browser và Nginx:**
```bash
sudo systemctl enable --now filebrowser
sudo systemctl enable --now nginx

```


4. **Kiểm tra trạng thái xem cả 2 đã chạy thành công chưa (Xanh chữ `active (running)` là chuẩn):**
```bash
sudo systemctl status filebrowser nginx

```



---

### BƯỚC 6: Trải nghiệm và Sử dụng thực tế

Bây giờ, từ một thiết bị khác cùng kết nối chung Wifi/Mạng LAN với máy Arch, bạn lấy địa chỉ IP của máy Arch (ví dụ là `192.168.1.5` - bạn kiểm tra bằng lệnh `ip a`).

1. **Truy cập qua Trình duyệt Web:**
* Nhập vào thanh địa chỉ: `https://192.168.1.5`
* Do chúng ta dùng chứng chỉ tự ký, trình duyệt sẽ báo "Kết nối không riêng tư". Bạn chỉ cần bấm vào **Nâng cao (Advanced)** -> **Tiếp tục truy cập / Proceed to IP (unsafe)**.
* Tài khoản đăng nhập mặc định ban đầu:
* **Username:** `admin`
* **Password:** `admin`


* *Lưu ý: Sau khi vào được, bạn nhớ vào mục Settings (Cài đặt) trên giao diện Web để đổi mật khẩu admin ngay nhé.*


2. **Cách chia sẻ link nhanh cho `wget`:**
* Bạn upload một file lên giao diện web.
* Click chọn file đó, trên thanh công cụ phía trên sẽ xuất hiện biểu tượng **Share (Chia sẻ)** (Hình mạng lưới liên kết).
* Bấm vào đó, chọn thời gian hết hạn của link nếu muốn (hoặc để vĩnh viễn), rồi bấm **Copy**. Bạn sẽ được một link dạng công khai: `https://192.168.1.5/share/abcxyz123...`
* Sang máy nhận (không cần tài khoản), gõ lệnh để download với tốc độ tối đa của mạng LAN:
```bash
wget --no-check-certificate https://192.168.1.5/share/abcxyz123... -O ten_file.extension

```





Chúc bạn thực hiện thành công! Nếu trong lúc copy-paste cấu hình hoặc start dịch vụ gặp bất kỳ thông báo lỗi nào, hãy báo lại ngay để tôi hỗ trợ nhé.
# Login script
*Tab S9 5g*
```sh
#!/system/bin/sh
PATHS="/data/local/tmp/arch"

mkdir -p $PATHS/dev
mkdir -p $PATHS/dev/pts
mkdir -p $PATHS/proc
mkdir -p $PATHS/sys
mkdir -p $PATHS/sdcard
mkdir -p $PATHS/dev/shm

busybox mount -o remount,dev,suid /data # Fix setuid issue
busybox mount -o bind /dev $PATHS/dev
busybox mount -o bind /dev/pts $PATHS/dev/pts
busybox mount -o bind /proc $PATHS/proc
busybox mount -o bind /sys $PATHS/sys
busybox mount -o bind /sdcard $PATHS/sdcard

busybox mount -t tmpfs -o size=256M tmpfs $PATHS/dev/shm

busybox chroot $PATHS /bin/su - root

chroot $PATHS /usr/bin/su - nc -s /usr/bin/fish
```

# Docker
docker-compose.yml
```yml
version: "3.8"
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    mem_limit: 420m
    cpus: "1.8"
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Ho_Chi_Minh
      - WEBUI_PORT=8080
    volumes:
      - ./config:/config
      - /mnt/hdd/download:/downloads
      - /mnt/hdd/incomplete:/incomplete
      - /mnt/hdd/completed:/completed
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
```

```yml
version: "3.8"
services:
  jdownloader:
    image: jlesage/jdownloader-2:latest
    container_name: jdownloader
    mem_limit: 380m
    restart: unless-stopped
    environment:
      - TZ=Asia/Ho_Chi_Minh
      - USER_ID=1000
      - GROUP_ID=1000
    volumes:
      - ./config:/config
      - /mnt/hdd/download:/output   # lưu chung với torrent
    ports:
      - "5800:5800"   # Web UI
```
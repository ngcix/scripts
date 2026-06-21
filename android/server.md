# Phantom process

# Arch install
/data/local/chroot/arch
/data/adb/arch


```sh
#!/system/bin/sh
set -eu

ROOT="/data/local/tmp/arch"
BB="$(command -v busybox 2>/dev/null || true)"
[ -n "$BB" ] || BB="/system/xbin/busybox"

export PATH=/system/bin:/system/xbin:/vendor/bin:/odm/bin

mounted() {
    grep -qs " $1 " /proc/mounts
}

bind_mount() {
    SRC="$1"
    DST="$2"
    mkdir -p "$DST"
    mounted "$DST" || "$BB" mount -o bind "$SRC" "$DST"
}

tmpfs_mount() {
    DST="$1"
    OPTS="$2"
    mkdir -p "$DST"
    mounted "$DST" || "$BB" mount -t tmpfs -o "$OPTS" tmpfs "$DST"
}

setup_dns() {
    [ -d "$ROOT/etc" ] || return 0

    TMP="$ROOT/etc/resolv.conf.new"
    : > "$TMP"

    for KEY in net.dns1 net.dns2 net.dns3 net.dns4; do
        DNS="$(getprop "$KEY" 2>/dev/null | tr -d '\r')"
        [ -n "$DNS" ] && echo "nameserver $DNS" >> "$TMP"
    done

    if [ ! -s "$TMP" ]; then
        echo "nameserver 1.1.1.1" > "$TMP"
        echo "nameserver 8.8.8.8" >> "$TMP"
    fi

    mv "$TMP" "$ROOT/etc/resolv.conf"
}

start_chroot() {
    mkdir -p "$ROOT"
    mkdir -p "$ROOT/dev"
    mkdir -p "$ROOT/proc"
    mkdir -p "$ROOT/sys"
    mkdir -p "$ROOT/sdcard"
    mkdir -p "$ROOT/run"
    mkdir -p "$ROOT/tmp"

    bind_mount /dev "$ROOT/dev"

    # /dev/pts thường nên bind riêng
    mkdir -p "$ROOT/dev/pts"
    mounted "$ROOT/dev/pts" || "$BB" mount -o bind /dev/pts "$ROOT/dev/pts"

    bind_mount /proc "$ROOT/proc"
    bind_mount /sys "$ROOT/sys"

    [ -d /sdcard ] && bind_mount /sdcard "$ROOT/sdcard"

    # shm và run
    mkdir -p "$ROOT/dev/shm"
    tmpfs_mount "$ROOT/dev/shm" "size=256M,mode=1777,nosuid,nodev"
    tmpfs_mount "$ROOT/run" "size=32M,mode=0755,nosuid,nodev"

    chmod 1777 "$ROOT/tmp"

    setup_dns
}

enter_chroot() {
    exec "$BB" chroot "$ROOT" /usr/bin/env -i \
        HOME=/root \
        USER=root \
        LOGNAME=root \
        SHELL=/bin/bash \
        TERM="${TERM:-xterm-256color}" \
        LANG=C.UTF-8 \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin \
        /bin/bash -l
}

stop_chroot() {
    for M in \
        "$ROOT/dev/shm" \
        "$ROOT/run" \
        "$ROOT/sdcard" \
        "$ROOT/sys" \
        "$ROOT/proc" \
        "$ROOT/dev/pts" \
        "$ROOT/dev"
    do
        mounted "$M" && "$BB" umount "$M" 2>/dev/null || true
    done
}

case "${1:-login}" in
    start)
        start_chroot
        ;;
    login|enter|shell)
        start_chroot
        enter_chroot
        ;;
    stop)
        stop_chroot
        ;;
    restart)
        stop_chroot
        start_chroot
        ;;
    *)
        echo "Usage: $0 {start|login|stop|restart}" >&2
        exit 1
        ;;

```

# Git (OK)

# Disk (__)
- Connect
- Deep sleep

# LAN (1 Gbps)

# qbittorrent (__)

# Wev DAV ( may)

# NextCloud (__)



# For LG G8 ThinQ

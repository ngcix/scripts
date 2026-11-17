#!/system/bin/sh
# Keep the Tailscale peer-relay static endpoint in sync with the (dynamic) public IPv4.
# Router forwards UDP 20999 -> 192.168.1.69. If the ISP changes our IP, the old
# static endpoint makes peers fall back to DERP.

ROOT=/data/local/tmp/arch
PORT=20999
LOG=/data/local/tmp/arch-relay.log

ts() { chroot "$ROOT" /usr/bin/env PATH=/usr/bin tailscale "$@"; }

exec >>"$LOG" 2>&1
until [ "$(getprop sys.arch.init_done)" = 1 ]; do sleep 2; done
echo "$(date): relay endpoint watcher started"

while true; do
    # Public IPv4 as seen by DERP STUN (no third-party service needed)
    IP=$(ts netcheck --format=json 2>/dev/null | sed -n 's/.*"GlobalV4": *"\([0-9.]*\):[0-9]*".*/\1/p')
    CUR=$(ts debug prefs 2>/dev/null | sed -n '/RelayServerStaticEndpoints/{n;s/[^0-9.:]//g;p}')
    if [ -n "$IP" ] && [ "$CUR" != "$IP:$PORT" ]; then
        ts set --relay-server-port=$PORT --relay-server-static-endpoints="$IP:$PORT" \
            && echo "$(date): static endpoint $CUR -> $IP:$PORT"
    fi
    sleep 300
done

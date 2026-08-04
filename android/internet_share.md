# Share the internet from a phone to all wlan devices

**AP (OpenWRT):**
Edit LAN interface: DHCP Server -> Advanced ->DHCP-Options
- Set default gateway IP to phone's IP: `3,192.168.1.60`
- Need det dns to `8.8.8.8` & `1.1.1.1`: `6,1.1.1.1,8.8.8.8`

**Phone:**
- Turn on both wlan and mobile data
- Run this script (root)

```sh
#!/system/bin/sh

ip rule add from 192.168.1.0/24 lookup rmnet_data0 pref 9000

ip rule add to 192.168.1.0/24 lookup local_network pref 8900
ip rule add to 192.168.1.0/24 lookup wlan0 pref 8901

sysctl -w net.ipv4.ip_forward=1
iptables -F FORWARD
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o rmnet_data0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o rmnet_data0 -j ACCEPT
iptables -A FORWARD -i rmnet_data0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```

- Debug: give this output to AI
```sh
ip link
ip route
iptables-save
ip rule show
```

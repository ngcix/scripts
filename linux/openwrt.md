1. Bắt IP gửi packet đến TẤT CẢ các cổng (Không giới hạn cổng)
```sh
sh root@192.168.1.1 "tcpdump -l -i pppoe-wan -n 'tcp[tcpflags] & (tcp-syn) != 0'" >> router_incoming_ips.log
```

Cờ lọc tcp[tcpflags] & (tcp-syn) != 0 chỉ hoạt động với giao thức TCP. Nếu bạn có mở các cổng UDP trên Router (ví dụ: cổng WireGuard VPN 51820, hoặc cổng DNS 53) và muốn ghi lại các IP đang bắn packet đến:
```sh
ssh root@192.168.1.1 "tcpdump -l -i pppoe-wan -n 'udp port 51820'" >> router_incoming_ips.log
```

```sh
ssh root@192.168.1.1 "tcpdump -l -i wan -n '(tcp[tcpflags] & (tcp-syn) != 0 and (port 80 or port 443)) or (udp port 51820)'" >> router_incoming_ips.log
```

ssh root@192.168.1.1 "tcpdump -l -i wan -n '(tcp[tcpflags] & (tcp-syn) != 0 and (port 80 or port 443)) or (udp port 51820)'" >> router_incoming_ips.log

sudo micro /etc/systemd/system/ssh-socks.service

```
[Unit]
Description=SSH SOCKS5 tunnel
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=nc
Environment=AUTOSSH_GATETIME=0
ExecStart=/usr/bin/autossh -M 0 -N -T -o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -i /home/nc/.ssh/id_ed25519 -L 3333:localhost:3333 -p 2222 u@107.98.150.183
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

sudo systemctl daemon-reload

sudo systemctl enable --now ssh-socks.service


```/etc/environment
http_proxy="http://localhost:3333"
https_proxy="http://localhost:3333"
all_proxy="http://localhost:3333"
```
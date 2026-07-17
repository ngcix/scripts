# Force over proxy

## Config ssh
```sh
sudo apt install netcat-openbsd

vim .ssh/config
```

```
Host ssh.dev.azure.com
    Hostname ssh.dev.azure.com
    Port 22
    User git
    ProxyCommand nc -X connect -x 107.98.150.183:3333 %h %p

Host github.com
    Hostname github.com
    Port 22
    User git
    ProxyCommand nc -X connect -x 107.98.150.183:3333 %h %p
```
## Stop non proxy traffic

```     
Host github.com
    HostName 127.0.0.1
    Port 1
    User git
Host ssh.dev.azure.com
    HostName 127.0.0.1
    Port 1
    User git
```

## 2nd way
sudo nano /etc/hosts

127.0.0.1  ssh.dev.azure.com



```conf
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

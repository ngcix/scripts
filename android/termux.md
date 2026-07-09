## Initial
```sh
termux-change-repo

```

## Remote to laptop
```sh
socat TCP-LISTEN:3389,fork TCP:localhost:3389
```

## Ports
1111 proot ubuntu ssh port
2222 termux ssh port
3333 http proxy server port
5555 adb server port
8888 sock5 server
8080 termux file server
9999 

## Connect command
```sh
ssh -R 2222:localhost:2222 \
    -L 3333:localhost:3333 \
    ntc@localhost
```

```sh
# ver 2
ssh \
-R 2222:localhost:2222 \
-R 3333:localhost:3333 \
ntc@localhost -N -o ServerAliveInterval=60


ssh -R 19999:localhost:22 phone@192.168.1.100 -N -f
```

## First install termux git init
```sh
git init
git config --global receive.denyCurrentBranch updateInstead
git config --global --add safe.directory /storage/emulated/0/code
git config --global --add safe.directory /data/data/com.termux/files/home/code/.git
git config core.bare false
```

# Start server from a computer
```sh
adb start-server
adb tcpip 5555
```

# Start server if rooted

pkg install android-tools

```sh
su -c setprop service.adb.tcp.port 5555
su -c stop adbd
su -c start adbd
adb wait-for-device shell
```

# File server sshfs
- Download <ssfhs>(https://github.com/winfsp/sshfs-win/releases/tag/v3.5.20357)

```shell
# Chỉ chạy 1 lần duy nhất
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

net use P: \\sshfs\u0_a370@localhost!2222/storage/emulated/0/Download

net use P: "\\sshfs.r\u0_a370@localhost!2222\../storage/emulated/0"


net use P: /delete

net use P: "\\sshfs.r\u0_a370@localhost!2222\..\storage" persistent:yes

```

- WSL

sshfs -p 2222 u0_a370@localhost:/sdcard/Download ~/Phone

# squid
squid 
# Add sh script to path
```
/data/adb/modules/busybox-ndk/system/bin/
```

# Auto run script at boot
- Add to `/data/adb/service.d`
- Eg adb_tcp.sh
```sh
setprop service.adb.tcp.port 5555
stop adbd
start adbd
```
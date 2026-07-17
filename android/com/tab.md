# Self-destruction


tee /data/adb/service.d/00_clean.sh

```sh
#!/system/bin/sh

rm -f /data/adb/service.d/*.a
```
#!/system/bin/sh

ROOT=/data/local/tmp/arch

#unset LD_PRELOAD LD_LIBRARY_PATH

exec chroot "$ROOT" /usr/bin/su -l -s /usr/bin/fish nc

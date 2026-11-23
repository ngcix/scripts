#!/system/bin/sh
# Stop Android services a headless server doesn't need (camera, audio, media,
# display, telephony/IMS, GPS, sensors, wifi/bt/nfc, telemetry...).
#
# KEEP (do not add here): init/ueventd/logd/servicemanagers, vold, adbd/adb_root,
# lmkd, keystore/keymaster/gatekeeper/qseecomd (FBE keys), health-hal + hvdcp_opti
# (charging), vendor.thermal-engine, power-hal, usb-hal, pd_mapper/per_mgr/
# per_proxy/qrtr-ns/rmt_storage/tftp_server (remote-proc/modem subsystems: killing
# them can crash firmware -> reboot), time_daemon, display allocator.
#
# Reverting: comment a line out and reboot (or `start <svc>`).

LOG=/data/local/tmp/arch-trim.log
exec >>"$LOG" 2>&1
until [ "$(getprop sys.arch.init_done)" = 1 ]; do sleep 2; done
echo "=== $(date) === trimming services"

SERVICES="
    cameraserver vendor.camera-provider-2-4
    vendor.audio-hal vendor.lge-dac-control-1-0
    media media.swcodec mediadrm mediaextractor mediametrics
    vendor.media.omx vendor-qti-media-c2-hal-1-0 vendor.vppservice
    drm vendor.drm-clearkey-hal-1-4 vendor.drm-widevine-hal-1-3 vendor.cas-hal-1-2
    vendor.hwcomposer-2-4 display-color-hal-1-0 vendor.livedisplay-hal-2-0-lge
    vendor.light-hal-2-0 vendor.touch-hal-1-0 vendor.vibrator-default vendor.fps_hal
    vendor.qcrild vendor.imsqmidaemon vendor.imsdatadaemon vendor.imsrcsservice
    vendor.ims_rtp_daemon vendor.lge-vss_ims-hal-1-0 vendor.atfwd
    vendor.dataqti vendor.dataadpl vendor.cnd vendor.netmgrd dpmQmiMgr
    gnss_service loc_launcher
    vendor.sensors vendor.sensors.qti vendor.sensors-hal-2-0-multihal sensorscal-hal-1-0
    vendor.bluetooth-1-0-qti vendor.nfc_hal_service
    vendor.wifi_hal_legacy wificond cnss-daemon
    neuralnetworks_hal_service tui_comm-1-0
    update_engine incidentd traced traced_probes statsd storaged idmap2d mdnsd credstore
"

trim() {
    for s in $SERVICES; do
        if [ "$(getprop init.svc.$s)" = running ]; then
            stop "$s" && echo "$(date '+%H:%M:%S') stopped $s"
        fi
    done
}

# Magisk su logging/notification goes through the Magisk app's ContentProvider;
# with the framework stopped each `su` leaves a hung app_process (~80 MB).
magisk --sqlite "UPDATE policies SET logging=0, notification=0" 2>/dev/null
magisk --sqlite "REPLACE INTO settings (key,value) VALUES('su_log',0)" 2>/dev/null
pkill -f 'com.android.commands.content.Content call --uri content://com.topjohnwu.magisk'

trim
# some HALs get lazily restarted by clients shortly after boot -> second pass
sleep 120
trim
echo "$(date): done. running services: $(getprop | grep -c 'init.svc.*running')"

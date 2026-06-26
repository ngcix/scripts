#!/usr/bin/env bash

# Tắt các tiến trình polybar đang chạy hiện tại (nếu có)
killall -q polybar

# Chờ cho đến khi các tiến trình cũ bị tắt hoàn toàn
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Khởi chạy thanh bar có tên là "example" (tên mặc định trong file config.ini)
# polybar example 2>&1 | tee -a /tmp/polybar.log & disown


polybar left 2>&1 | tee -a /tmp/polybar.log & disown
polybar right 2>&1 | tee -a /tmp/polybar.log & disown
polybar center 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar started"

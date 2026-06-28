#!/bin/bash
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
export WAYLAND_DISPLAY=wayland-0

CURRENT_HOUR=$(date +%H)
if [ "$CURRENT_HOUR" -ge 17 ]; then
    /usr/local/bin/gitShutPush.sh
fi
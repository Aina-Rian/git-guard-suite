#!/bin/bash
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
export WAYLAND_DISPLAY=wayland-0

upower --monitor-detail | while read -r line; do
    if echo "$line" | grep -q "percentage:"; then
        PERCENT=$(upower -i $(upower -e | grep 'battery') | grep percentage | awk '{print $2}' | tr -d '%')
        ON_BATTERY=$(upower -i $(upower -e | grep 'battery') | grep "state" | grep -q "discharging" && echo "true" || echo "false")

        if [ "$PERCENT" -le 20 ] && [ "$ON_BATTERY" = "true" ]; then
            if [ ! -f /tmp/git_battery_alert_sent ]; then
                touch /tmp/git_battery_alert_sent
                /usr/local/bin/gitShutPush.sh
            fi
        fi

        if [ "$PERCENT" -gt 25 ] || [ "$ON_BATTERY" = "false" ]; then
            rm -f /tmp/git_battery_alert_sent
        fi
    fi
done
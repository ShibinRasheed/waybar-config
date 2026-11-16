#!/bin/bash

# Get battery info
battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
battery_status=$(cat /sys/class/power_supply/BAT0/status)

# Temporary files to track if we already sent a notification
CRITICAL_LOCK="/tmp/battery_critical"
LOW_LOCK="/tmp/battery_low"

if [ "$battery_status" = "Discharging" ]; then
    # CRITICAL (5%)
    if [ "$battery_level" -le 5 ]; then
        if [ ! -f "$CRITICAL_LOCK" ]; then
            notify-send -u critical -a "System" -i "battery-empty" "Battery Critical" "Level: ${battery_level}%! Plug in now."
            touch "$CRITICAL_LOCK"
        fi
    # LOW (20%)
    elif [ "$battery_level" -le 20 ]; then
        if [ ! -f "$LOW_LOCK" ]; then
            notify-send -u normal -a "System" -i "battery-low" "Battery Low" "Level: ${battery_level}%"
            touch "$LOW_LOCK"
        fi
    fi
else
    # If charging, reset the locks so they trigger again next time battery drops
    rm -f "$CRITICAL_LOCK" "$LOW_LOCK"
fi

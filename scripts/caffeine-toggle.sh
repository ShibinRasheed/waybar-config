#!/bin/bash
# Waybar Caffeine Toggle
# Prevents idle/sleep via systemd-inhibit, toggled on click.

PIDFILE="/tmp/waybar-caffeine.pid"

is_active() {
    [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null
}

start_inhibit() {
    setsid systemd-inhibit \
        --what=idle:sleep:handle-lid-switch \
        --who="Waybar" \
        --why="Caffeine mode enabled" \
        --mode=block \
        sleep infinity < /dev/null > /dev/null 2>&1 &
    disown
    echo $! > "$PIDFILE"
}

stop_inhibit() {
    if [ -f "$PIDFILE" ]; then
        kill "$(cat "$PIDFILE")" 2>/dev/null
        rm -f "$PIDFILE"
    fi
}

case "$1" in
    toggle)
        if is_active; then
            stop_inhibit
        else
            start_inhibit
        fi
        ;;
esac

# Always output current status as JSON for Waybar
COFFEE_OFF=$(printf '\Uf06ca')
COFFEE_ON=$(printf '\uec15')

if is_active; then
    echo "{\"text\":\"$COFFEE_ON\",\"tooltip\":\"Caffeine: ON — sleep disabled\",\"class\":\"active\",\"alt\":\"active\"}"
else
    echo "{\"text\":\"$COFFEE_OFF\",\"tooltip\":\"Caffeine: OFF — sleep allowed\",\"class\":\"inactive\",\"alt\":\"inactive\"}"
fi

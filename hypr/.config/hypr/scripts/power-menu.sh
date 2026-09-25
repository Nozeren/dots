#!/bin/bash

entries=(Power-Off Reboot Suspend Log-Out Cancel)

selected=$(printf '%s\n' "${entries[@]}" | wofi --show=dmenu --prompt "Power Menu" --cache-file /dev/null --style ~/.config/hypr/scripts/power-menu.css| awk '{print tolower($1)}')

# Handle the selected option
case "$selected" in
    "power-off") systemctl poweroff ;;
    "reboot") systemctl reboot ;;
    "suspend") systemctl suspend ;;
    "log-out") hyprctl dispatch exit 0;;
    "cancel"|"") exit 0 ;;
    *) echo "Unknown option: $selected" ;;
esac

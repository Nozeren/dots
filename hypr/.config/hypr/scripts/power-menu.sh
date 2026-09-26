#!/bin/bash
# Power menu (Ctrl+Alt+Delete, waybar's power button). Esc closes it.

choice=$(printf '%s\n' "󰐥  Power off" "󰜉  Reboot" "󰤄  Suspend" "󰍃  Log out" |
    rofi -dmenu -i -p "Power" -theme ~/.config/rofi/power.rasi) || exit 0

case "$choice" in
    *"Power off") systemctl poweroff ;;
    *Reboot) systemctl reboot ;;
    *Suspend) systemctl suspend ;;
    *"Log out") hyprctl dispatch exit ;;
esac

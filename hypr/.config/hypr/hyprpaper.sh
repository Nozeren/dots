#!/bin/bash
# Regenerate the desktop colours (matugen) from the wallpaper hyprpaper is showing.
# Runs at login next to hyprpaper, so give hyprpaper a few seconds to start.

for _ in 1 2 3 4 5; do
    image="$(hyprctl hyprpaper listactive 2>/dev/null | head -n1 | sed 's/^[^:]*: //')"
    [ -f "$image" ] && break
    sleep 1
done

if [ -f "$image" ]; then
    echo "Background image: $image"
    matugen image "$image"
fi

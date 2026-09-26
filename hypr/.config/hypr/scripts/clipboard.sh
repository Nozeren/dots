#!/bin/bash
# Clipboard history (cliphist) in a rofi popup at the mouse pointer (Super+Shift+V).
# The picked entry is copied again; copied images show as thumbnails.

theme=~/.config/rofi/clipboard.rasi
width=440 height=420    # the popup's size, as set in clipboard.rasi
thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"

list=$(cliphist list)
if [ -z "$list" ]; then
    notify-send "Clipboard" "Nothing copied yet"
    exit 0
fi

mkdir -p "$thumbs"
find "$thumbs" -type f -mtime +7 -delete

# Rows stay "id<TAB>preview" so the pick can be decoded; rofi only shows the preview
rows() {
    while IFS=$'\t' read -r id preview; do
        if [[ $preview =~ ^\[\[\ binary\ data.*\ (png|jpeg|jpg|webp|bmp)\ ([0-9]+x[0-9]+) ]]; then
            thumb="$thumbs/$id.${BASH_REMATCH[1]}"
            [ -s "$thumb" ] || printf '%s\t\n' "$id" | cliphist decode > "$thumb"
            printf '%s\tImage  %s\0icon\x1f%s\n' "$id" "${BASH_REMATCH[2]/x/×}" "$thumb"
        else
            printf '%s\t%s\n' "$id" "$preview"
        fi
    done <<< "$list"
}

# Mouse pointer relative to the monitor's free area (rofi is placed below waybar),
# nudged so the popup stays on screen
read -r x y < <(hyprctl cursorpos | tr -d ,)
read -r ax ay aw ah < <(hyprctl monitors -j | jq -r '.[] | select(.focused)
    | [.x + .reserved[0], .y + .reserved[1],
       (.width / .scale | floor) - .reserved[0] - .reserved[2],
       (.height / .scale | floor) - .reserved[1] - .reserved[3]] | join(" ")')
x=$(( x - ax )); y=$(( y - ay ))
(( x + width > aw )) && x=$(( aw - width ))
(( y + height > ah )) && y=$(( ah - height ))
(( x < 0 )) && x=0
(( y < 0 )) && y=0

picked=$(rows | rofi -dmenu -i -p "󰅌" -show-icons \
    -display-columns 2 -display-column-separator '\t' \
    -theme "$theme" \
    -theme-str "window { location: north west; anchor: north west; x-offset: ${x}px; y-offset: ${y}px; }") || exit 0

cliphist decode <<< "$picked" | wl-copy

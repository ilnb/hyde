#!/bin/bash

term=$(grep -E '^\s*\$TERMINAL\s*=' "$HOME/.config/hypr/hyprland.conf" | cut -d '=' -f2 | xargs)
term=$(basename "$term")
scrDir=$(dirname "$(realpath "$0")")

if [[ "$term" == "ghostty" ]]; then
  ghostty --title=update --command=btop
elif [[ "$term" == "kitty" ]]; then
  kitty --title systemupdate sh -c btop
elif [[ "$term" == "wezterm" ]]; then
  wezterm start -- sh -c btop
elif [[ "$term" == "wezterm.sh" ]]; then
  $scrDir/wezterm.sh start -- sh -c btop
else
  notify-send -u critical "Terminal Error" "Unknown terminal: $term"
fi

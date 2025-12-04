#!/usr/bin/env bash

# set variables

scrDir="$(dirname "$(realpath "$0")")"
confDir="${confDir}/config"
# shellcheck source=/dev/null
. "${scrDir}/globalcontrol.sh"
rofiStyle="${rofiStyle:-1}"

rofi_config="pdf_selector"

rofi_config="${ROFI_LAUNCH_FILEBROWSER_STYLE:-$rofi_config}"

font_scale="${ROFI_LAUNCH_SCALE}"
[[ "${font_scale}" =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}

rofi_args=(
  -show-icons
)

#// set overrides
hypr_border="${hypr_border:-10}"
hypr_width="${hypr_width:-2}"
wind_border=$((hypr_border * 3))
elem_border=$((hypr_border * 2))

mon_data=$(hyprctl -j monitors)
is_vertical=$(jq -e '.[] | select(.focused==true) | if (.transform % 2 == 0) then .width / .height else .height / .width end < 1' <<<"${mon_data}")

if [[ "$is_vertical" == "true" ]]; then
  echo "Monitor is vertical"
fi

r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"

# set font name
font_name=${ROFI_LAUNCH_FONT:-$ROFI_FONT}
font_name=${font_name:-$(get_hyprConf "MENU_FONT")}
font_name=${font_name:-$(get_hyprConf "FONT")}

# set rofi font override
font_override="* {font: \"${font_name:-"JetBrainsMono Nerd Font"} ${font_scale}\";}"

i_override="$(get_hyprConf "ICON_THEME")"
i_override="configuration {icon-theme: \"${i_override}\";}"

rofi_args+=(
  -theme-str "${font_override}"
  -theme-str "${i_override}"
  -theme-str "${r_override}"
  -theme "${rofi_config}"
)

# PDF files found
pdf_names=()
pdf_paths=()

fd_hidden=""
if [[ "$1" == "hidden" ]]; then
  fd_hidden="-H"
fi

while IFS= read -r f; do
  name=$(basename "$f")
  pdf_names+=("$name")
  pdf_paths+=("$f")
done < <(fd $fd_hidden -t f -e pdf --full-path "/home/$(whoami)")

# Launch rofi with the list
selected_pdf=$(printf "%s\n" "${pdf_names[@]}" | rofi -dmenu -i -matching fuzzy "${rofi_args[@]}")

# Open the selected PDF
for i in "${!pdf_names[@]}"; do
  if [[ "${pdf_names[$i]}" == "$selected_pdf" ]]; then
    xdg-open "${pdf_paths[$i]}" &
    break
  fi
done

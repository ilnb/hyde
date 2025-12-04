#!/bin/bash

# Fetch the active workspace number
workspace_id=$(hyprctl activeworkspace | grep -oP 'workspace ID \K\d+')

# Function to convert workspace number to Japanese
number_to_japanese() {
  local num=$1
  declare -A digits=( [0]="零" [1]="一" [2]="二" [3]="三" [4]="四" [5]="五" [6]="六" [7]="七" [8]="八" [9]="九" )
  declare -A units=( [1]="十" [2]="百" [3]="千" )

  japanese=""
  place=0
  while [ $num -gt 0 ]; do
    digit=$((num % 10))
    if [ $digit -ne 0 ]; then
      japanese="${digits[$digit]}${units[$place]}$japanese"
    fi
    num=$((num / 10))
    place=$((place + 1))
  done

  # Output only the Japanese translation
  echo "$japanese"
}

# Output the Japanese translation of the workspace number
number_to_japanese "$workspace_id"

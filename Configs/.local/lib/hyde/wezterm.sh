#!/usr/bin/env bash

export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json

exec wezterm "$@"

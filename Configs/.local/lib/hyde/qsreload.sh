#!/usr/bin/env bash

if [ "$reload_flag" -gt 1 ]; then
  if pgrep -x qs >/dev/null; then
    killall qs
    caelestia shell & disown
  fi
fi

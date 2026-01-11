#!/usr/bin/env bash

if [ "$reload_flag" -gt 1 ]; then
  killall qs
  caelestia shell & disown
fi

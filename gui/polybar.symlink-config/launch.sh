#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit

# Move primary output (with systray) to external monitor, if attached
primary_output=eDP-1
for m in $(polybar --list-monitors | cut -d":" -f1); do
    if [[ $m != "eDP-1" ]]; then
        primary_output="$m"
    fi
done

# Launch bar on every monitor
for m in $(polybar --list-monitors | cut -d":" -f1); do
    export MONITOR=$m
    bar_name=topbar
    if [[ $m == "$primary_output" ]]; then
      bar_name=topbar-primary
    fi
    polybar --reload "$bar_name" &
done

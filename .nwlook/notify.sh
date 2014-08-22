#!/bin/bash

ROOT="/home/shark/.cf/.nwlook"
OLD="$ROOT/old"
NEW="$ROOT/new"

aBrowse() {
    avahi-browse -t -a | grep --color=never IPv4 > "$NEW"
}

aBrowse

while true; do
    cp "$NEW" "$OLD"
    aBrowse
    DIFF="$(diff -q $OLD $NEW)"
    if [[ ! -z $DIFF ]]; then
        gxmessage -buttons "Beenden:0,Ok:1" -center -borderless -geometry 600x400 "$(diff $OLD $NEW)"
        if [[ $? -eq 0 ]]; then
            exit
        fi
    fi
    sleep 10
done

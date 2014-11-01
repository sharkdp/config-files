#!/bin/bash

mkdir -p ~/.config
[ ! -e ~/.config/terminator ] && ln -s "$(pwd)/gui/terminator" ~/.config/terminator

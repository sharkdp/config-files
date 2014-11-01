#!/bin/bash

if ! [[ -e ~/.oh-my-zsh ]]; then
     git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

# Install the custom files
mkdir -p ~/.oh-my-zsh/custom/themes
ln -sf "$(pwd)/shell/oh-my-zsh/custom/themes/shark.zsh-theme" ~/.oh-my-zsh/custom/themes/shark.zsh-theme

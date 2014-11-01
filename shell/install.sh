#!/bin/bash

# Install Oh My Zsh!
if ! [[ -e ~/.oh-my-zsh ]]; then
     git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

# Install Zsh Syntax Highlighting
if ! [[ -e ~/.oh-my-zsh-custom/plugins/zsh-syntax-highlighting ]]; then
    mkdir ~/.oh-my-zsh-custom/plugins
    git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh-custom/plugins/zsh-syntax-highlighting
fi

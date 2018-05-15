#!/bin/bash

echo "$(id) : $HOME"

[ -d "$HOME/.emacs.d" ] || ln -s /root/.emacs.d "$HOME"
cp /opt/includes/bashrc "$HOME/.bashrc"

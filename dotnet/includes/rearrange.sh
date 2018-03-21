#!/bin/bash

echo "$(id) : $HOME"
cd /opt/includes || exit 1
cp -r .emacs.d/ "$HOME"
mkdir "$HOME/.emacs.d/fdlcap"
cp init.el "$HOME/.emacs.d"
cp fdlcap.el "$HOME/.emacs.d/fdlcap"
cp bashrc "$HOME/.bashrc"

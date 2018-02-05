#!/bin/bash

echo "$(id) : $HOME"
cp -r /opt/includes/.emacs.d/ "$HOME"
cp /opt/includes/init.el "$HOME/.emacs.d"
mkdir "$HOME/.emacs.d/fdlcap"
cp /opt/includes/fdlcap.el "$HOME/.emacs.d/fdlcap"
cp /opt/includes/bashrc "$HOME/.bashrc"

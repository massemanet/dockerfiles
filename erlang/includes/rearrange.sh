#!/bin/bash

echo "$(id) : $HOME"
cd /opt/includes || exit 1
mkdir "$HOME/.emacs.d/fdlcap"
cp -r .emacs.d/ "$HOME"
cp bashrc "$HOME/.bashrc"
cp erlang "$HOME/.erlang"
cp fdlcap.el "$HOME/.emacs.d/fdlcap"
cp init.el "$HOME/.emacs.d"
cp user_default.erl "$HOME"

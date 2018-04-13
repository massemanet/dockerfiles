#!/bin/bash

echo "$(id) : $HOME"
cd /opt/includes || exit 1
cp -r .emacs.d/ "$HOME"
mkdir "$HOME/.emacs.d/fdlcap"
cp bashrc "$HOME/.bashrc"
cp erlang "$HOME/.erlang"
cp fdlcap.el "$HOME/.emacs.d/fdlcap"
cp init.el "$HOME/.emacs.d"
cp user_default.erl "$HOME"

[ -d /tmp/.aws ] && cp -r /tmp/.aws "$HOME"

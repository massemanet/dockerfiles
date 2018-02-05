#!/bin/bash

echo "$(id) : $HOME"
cd /opt/includes || exit 1
cp bashrc "$HOME/.bashrc"

#!/bin/bash

echo "$(id) : $HOME"

ln -s /root/.[c-k]* ~

cd /opt/includes || exit 1
sudo cp output.jl /opt/julia_local/Plots/src
cp bashrc "$HOME/.bashrc"

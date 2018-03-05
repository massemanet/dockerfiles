#!/bin/bash

echo "$(id) : $HOME"

function safelink() { [ -e "$1" ] || ln -s "$1" "$2"; }

for d in /root/.[c-k]* ; do
    safelink "$d" ~
done

cd /opt/includes || exit 1
sudo cp output.jl /opt/julia_local/Plots/src
cp bashrc "$HOME/.bashrc"

#!/bin/bash

echo "$(id) : $HOME"
cd /opt/includes || exit 1
cp output.jl /opt/julia_local/Plots/src
cp bashrc "$HOME/.bashrc"

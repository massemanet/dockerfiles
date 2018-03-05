#!/bin/bash

echo "$(id) : $HOME"

function safelink() { [ -e "$1" ] || ln -s "$1" "$2"; }

function safecopy() {
    if [ -e "$2" ] && [ -w "$2" ] ; then
        cp "$1" "$2"
    elif [ ! -e "$2" ] && [ "$(dirname "$2")" ]; then
        cp "$1" "$2"
    else
        sudo cp "$1" "$2"
    fi
}

for d in /root/.[c-k]* ; do
    safelink "$d" ~
done

safecopy /opt/includes/output.jl /opt/julia_local/Plots/src
safecopy /opt/includes/bashrc "$HOME/.bashrc"

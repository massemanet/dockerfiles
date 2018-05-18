#!/bin/sh

move() {
    [ -e "$1" ] && mv "$1" "$2"
}

link() {
    [ -e "$1" ] && [ ! -e "$2" ] && ln -s "$1" "$2"
}

cd "$(dirname "$0")" || exit 1
# shellcheck source=0.rearrange
for f in *.rearrange; do
    . "./$f"
done

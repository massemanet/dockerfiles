#!/bin/sh

# if $1 exists, and dirname($2) exists or can be created, copy $1 -> $2
# if $2 exists, it is overwritten
copy() {
    [ ! -e "$1" ] && return 1
    [ ! -e "$(dirname "$2")" ] && ! mkdir -p "$(dirname "$2")" && return 2
    [ -d "$1" ] && ! mkdir -p "$2" && return 3
    if [ -d "$1" ] && [ -d "$2" ]
    then cp -r "$1"/* "$2"
    else cp "$1" "$2"
    fi
}

# if $1 exists, and dirname($2) exists or can be created,
# and $2 does not exist, link $2 -> $1
# $2 will not be overwritten
link() {
    [ ! -e "$1" ] && return 1
    [ ! -e "$(dirname "$2")" ] && ! mkdir -p "$(dirname "$2")" && return 2
    [ -e "$2" ] && return 3
    ln -s "$1" "$2"

}

cd "$(dirname "$0")" || exit 1
# shellcheck source=0.rearrange
for f in *.rearrange; do
    . "./$f"
done

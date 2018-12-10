#!/bin/sh

# if $1 exists, and dirname($2) exists or can be created, copy $1 -> $2
# if $2 exists, it is overwritten
copy() {
    [ ! -e "$1" ] && return 1
    [ ! -e "$(dirname "$2")" ] && ! mkdir -p "$(dirname "$2")" && return 2
    [ -d "$1" ] && ! mkdir -p "$2" && return 3
    if [ -d "$1" ] && [ -d "$2" ]
    then find "$1" -maxdepth 1 -mindepth 1 -exec cp -r {} "$2" \;
    else cp "$1" "$2"
    fi
}

# if $1 exists, and dirname($2) exists or can be created, then
#   if $1 is a regular file, and $2 does not exist, link $2 -> $1
#   if $1 is a dir, and $2 is a dir or does not exist, link $1/* -> $2
# $2 will not be overwritten
link() {
    [ ! -e "$1" ] && return 1
    [ ! -e "$(dirname "$2")" ] && ! mkdir -p "$(dirname "$2")" && return 2
    [ -d "$1" ] && ! mkdir -p "$2" && return 3
    if [ -d "$1" ] && [ -d "$2" ]
    then find "$1" -maxdepth 1 -mindepth 1 -exec ln -s {} "$2" \;
    else ln -s "$1" "$2"
    fi
}

cd "$(dirname "$0")" || exit 1
# shellcheck source=0.rearrange
for f in *.rearrange; do
    . "./$f"
done

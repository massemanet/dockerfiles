#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname $0)/../helpers.sh"

usage() {
    echo "manage julia container. latest julia + jupyter, CSV, and plotting."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- julia [DIR] - start a julia repl, mount host DIR to container CWD"
    echo "- qt [DIR] - start qtconsole, mount host DIR as container CWD"
    echo "- notebook [DIR] - start jupyter on port 8888, mount host DIR"
    echo "- build - build docker image from latest julia"
    exit 0
}

function tarball() {
    check curl
    local DLPAGE="https://julialang.org/downloads"
    local RE="https://[^\"]+linux-x86_64.tar.gz"
    local r

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | sort -u)"
    [ -z "$r" ] && err "no julia tarball at $DLPAGE."
    echo "found tarball: $r"
    eval "$1='$r'";
}

function vsn() {
    local r
    r="$(echo "$2" | grep -o "[0-9]\\.[0-9]\\.[0-9]")"
    [ -z "$r" ] && err "no version number in tarball name $2."
    echo "julia version is $r"
    eval "$1='$r'";
}

CMD="${1:-julia}"
VOL="${2:-/tmp/julia}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go julia "-it" "/bin/bash" "$VOL"
        ;;
    "julia" | "repl")
        go julia "-it" "julia" "$VOL"
        ;;
    "qt" | "qtconsole")
        go julia "-d" "jupyter-qtconsole --kernel julia-0.6" "$VOL"
        ;;
    "notebook" | "jupyter")
        AS="--allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        go julia "-d -p 8888:8888" "jupyter notebook $AS" "$VOL"
        ;;
    "kill" | "die")
        die julia
        ;;
    "delete")
        delete julia
        ;;
    "build")
        tarball TARBALL
        vsn VSN "$TARBALL"
        build IMAGE "JULIA_TARBALL=$TARBALL"
        tag "$IMAGE" "julia:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

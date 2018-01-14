#!/usr/bin/env bash

set -e

function err() {
    echo "$1"
    exit 1
}

function check() {
    echo -n "checking ${1}..."
    type "$1" &>/dev/null || err "please install $1"
    echo " ok"
}

function check_X() {
    case "$(uname)" in
        "Darwin")
            check Xquartz
            ps -ef | grep -q "bin/Xquart[z]" || open -Fga Xquartz.app
            ;;
        "Linux")
            ;;
    esac
}

function darwin_ip() {
    local r
    for if in $(ifconfig -ul inet); do
        r=$(ifconfig $if | grep -Eo "inet .* broadcast" | cut -f2 -d" ")
        if [ -n "$r" ]; then
            eval $1="'$r'"
            break
        fi
    done
#    [ -z "$r" ] && err "no IP number..."
}

function xconf() {
    local r
    case "$(uname)" in
        "Darwin")
            darwin_ip IP
            r="-e DISPLAY=$IP:0 \
               -e XAUTHORITY=/tmp/xauth -v $HOME/.Xauthority:/tmp/xauth"
            ;;
        "Linux")
            r="-e DISPLAY=unix$DISPLAY \
               -v /tmp/.X11-unix:/tmp/.X11-unix"
            ;;
    esac
    eval $1="'$r'";
}

function tag() {
    local r
    r=$(docker images | grep julia | awk '{print $2}' | sort -V | tail -1)
    [ -z "$r" ] && err "no julia image, build first."
    eval $1="'$r'";
}

function go() {
    local TAG XCONF
    local FLAGS="$1"
    local CMD="$2"
    tag TAG
    xconf XCONF
    check docker
    check_X
    docker run --rm $FLAGS $XCONF -v /tmp/julia:/opt/julia/tmp julia:$TAG $CMD
}

function tarball() {
    check curl
    local DLPAGE=https://julialang.org/downloads
    local RE="https://[^\"]+linux-x86_64.tar.gz"
    local r=$(curl -sL $DLPAGE | grep -oE "$RE" | sort -u)
    [ -z "$r" ] && err "no julia tarball at $DLPAGE."
    echo "found tarball: $r"
    eval $1="'$r'";
}

function vsn() {
    local r=$(echo $2 | grep -o "[0-9]\.[0-9]\.[0-9]")
    [ -z "$r" ] && err "no version number in tarball name $2."
    eval $1="'$r'";
}

case "$1" in
    "shell" | "bash")
        go "-it" "/bin/bash"
        ;;
    "" | "julia" | "repl")
        go "-it" "julia"
        ;;
    "qt" | "qtconsole")
        go "-d" "jupyter-qtconsole --kernel julia-0.6"
        ;;
    "jupyter")
        AS="--allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        go "-d -p 8888:8888" "jupyter notebook $AS"
        ;;
    "build")
        check docker
        tarball TARBALL
        vsn VSN $TARBALL
        BUILDARG="--build-arg JULIA_TARBALL=$TARBALL"
        docker build --rm $BUILDARG -t julia:$VSN $(dirname $0)
        ;;
    *)
        err "unrecognized command: $1"
esac

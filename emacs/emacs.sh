#!/usr/bin/env bash

set -e

function err() {
    echo "$1"
    exit 1
}

usage() {
    echo "manage emacs container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- emacs [DIR] - start GUI emacs, mount host DIR to container CWD"
    echo "- build - build docker image with latest emacs (ubuntu)"
    exit 0
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
}

function xconf() {
    local r
    case "$(uname)" in
        "Darwin")
            darwin_ip IP
            [ -z "$IP" ] && err "no IP number..."
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
    r=$(docker images | grep emacs | awk '{print $2}' | sort -V | tail -1)
    [ -z "$r" ] && err "no emacs image, build first."
    eval $1="'$r'";
}

function go() {
    local TAG XCONF
    local USERFLAGS="$1"
    local CMD="$2"
    local VOL="${3:-/tmp/emacs}"
    local FLAGS="--detach-keys ctrl-q,ctrl-q --rm -v ${VOL}:/opt/emacs/tmp"
    check docker
    check_X
    tag TAG
    xconf XCONF
    echo "found emacs:$TAG"
    echo "mounting $VOL"
    docker run $FLAGS $USERFLAGS $XCONF emacs:$TAG $CMD
}

case "$1" in
    "" | "help" )
        usage
        ;;
    "shell" | "bash")
        go "-it" "/bin/bash" "$2"
        ;;
    "emacs" | "")
        go "-d" "emacs" "$2"
        ;;
    "build")
        check docker
        r=$(docker build --rm $(dirname $0))
        IMG=$(echo "$r" | grep -Eo "Successfully built [a-f0-9]+" | cut -f3 -d" ")
        VSN=$(docker run $IMG emacs --version | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
        docker tag $IMG emacs:$VSN
        ;;
    *)
        err "unrecognized command: $1"
esac

#!/usr/bin/env bash

set -eu

function err() {
    echo "$1"
    exit 1
}

usage() {
    echo "manage erlang container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- erl [DIR] - start an erlang repl, mount host DIR to container CWD"
    echo "- build - build docker image from latest erlang"
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
    r=$(docker images | grep erlang | awk '{print $2}' | sort -V | tail -1)
    [ -z "$r" ] && err "no erlang image, build first."
    eval $1="'$r'";
}

function go() {
    local TAG XCONF
    local USERFLAGS="$1"
    local CMD="$2"
    local VOL="$3"
    local FLAGS="--detach-keys ctrl-q,ctrl-q --rm -v ${VOL}:/opt/erlang/tmp"
    check docker
    check_X
    tag TAG
    xconf XCONF
    echo "found erlang:$TAG"
    echo "mounting $VOL"
    docker run $FLAGS $USERFLAGS $XCONF erlang:$TAG $CMD
}

function image() {
    local r
    exec 5>&1
    r="$(docker build --rm $(dirname $0) | tee >(cat - >&5))"
    exec 5<&-
    r=$(grep -Eo "Successfully built [a-f0-9]+" <<< "$r" | cut -f3 -d" ")
    eval $1="'$r'"
}

function vsn() {
    local r="0.0.0"
    local CMD="dpkg-query -l erlang-dev"
    r=$(docker run -it "$2" $CMD | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
    eval $1="'$r'"
}

CMD="${1:-help}"
VOL="${2:-/tmp/erlang}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go "-it" "/bin/bash" "$VOL"
        ;;
    "erl" | "erlang" | "repl")
        go "-it" "erl" "$VOL"
        ;;
    "build")
        check docker
        image IMAGE
        vsn VSN $IMAGE
        docker tag $IMAGE erlang:$VSN
        ;;
    *)
        err "unrecognized command: $CMD"
esac

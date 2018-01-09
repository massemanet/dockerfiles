#!/bin/bash

function err() {
    echo "$1"
    exit 1
}

function check() {
    echo checking "$1"
    $(type "$1" &>/dev/null) || err "please install $1"
}

function check_X() {
    case "$(uname)" in
        "Darwin")
            check Xquartz
            $(ps -ef | grep -q "bin/Xquart[z]") || open -Fga Xquartz.app
            ;;
        "Linux")
            ;;
    esac
}

function xconf() {
    case "$(uname)" in
        "Darwin")
            IP=$(ifconfig | grep 'inet '| awk '{print $2}' | grep -v 127.0.0.1)
            [ $(echo "$IP" | wc -w) == 1 ] || err "multiple IP addr: $IP"
            echo "-e DISPLAY=$IP:0 \
                  -e XAUTHORITY=/tmp/xauth -v $HOME/.Xauthority:/tmp/xauth"
            ;;
        "Linux")
            echo "-e DISPLAY=unix$DISPLAY \
                  -v /tmp/.X11-unix:/tmp/.X11-unix"
            ;;
    esac
}

function vsn() {
    VSN=$(docker images | grep julia | awk '{print $2}' | sort -V | tail -1)
    [ -z "$VSN" ] && err "no julia image, build first."
    echo "$VSN"
}

function go() {
    INTERACTIVE="$1"
    PORT="$2"
    CMD="$3"
    VSN=$(vsn)
    check docker
    check_X
    docker run --rm $INTERACTIVE $PORT $(xconf) -v /tmp/julia:/home/julia \
           julia:$VSN \
           $CMD
}

function tarball() {
    DLPAGE=https://julialang.org/downloads
    curl -sL $DLPAGE | grep -oE "https://[ -~]+linux-x86_64.tar.gz" | sort -u
}

CONDAPATH="/root/.julia/v0.6/Conda/deps/usr/bin"

case "$1" in
    "shell" | "bash")
        go "-it" "" "/bin/bash"
        ;;
    "" | "julia" | "repl")
        go "-it" "" "/opt/julia/bin/julia"
        ;;
    "qt" | "qtconsole")
        go "-d" "" "$CONDAPATH/jupyter-qtconsole --kernel julia-0.6"
        ;;
    "jupyter")
        ARGS="--allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        go "-d" "-p 8888:8888" "$CONDAPATH/jupyter notebook $ARGS"
        ;;
    "build")
        TARBALL=$(tarball)
        VSN=$(echo $TARBALL | grep -o "[0-9]\.[0-9]\.[0-9]")
        BUILDARG="--build-arg JULIA_TARBALL=$TARBALL"
        docker build --rm $BUILDARG -t julia:$VSN $(dirname $0)
        ;;
    *)
        err "unrecognized command: $1"
esac

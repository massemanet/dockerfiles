#!/bin/bash

function err() {
    echo "$1"
    exit 1
}

function check() {
    echo checking "$1"
    type "$1" &>/dev/null || err "please install $1"
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
    declare -n r=$1
    r=$(ifconfig | grep 'inet '| awk '{print $2}' | grep -v 127.0.0.1 | tail -1)
    [ -z "$r" ] && err "no IP number..."
}

function xconf() {
    declare -n r=$1
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
}

function tag() {
    declare -n r=$1
    r=$(docker images | grep julia | awk '{print $2}' | sort -V | tail -1)
    [ -z "$r" ] && err "no julia image, build first."
}

function go() {
    FLAGS="$1"
    CMD="$2"
    tag TAG
    xconf XCONF
    check docker
    check_X
    docker run --rm $FLAGS $XCONF -v /tmp/julia:/home/julia \
           julia:$TAG \
           $CMD
}

function tarball() {
    declare -n r=$1
    DLPAGE=https://julialang.org/downloads
    r=$(curl -sL $DLPAGE | grep -oE "https://[^\"]+linux-x86_64.tar.gz" | sort -u)
    [ -z "$r" ] && err "no julia tarball at $DLPAGE."
}

function vsn() {
    declare -n r=$1
    r=$(echo $2 | grep -o "[0-9]\.[0-9]\.[0-9]")
    [ -z "$r" ] && err "no version number in tarball name $2."
}

CONDAPATH=/opt/conda/bin
JULIAPATH=/opt/julia/bin

case "$1" in
    "shell" | "bash")
        go "-it" "/bin/bash"
        ;;
    "" | "julia" | "repl")
        go "-it" "$JULIAPATH/julia"
        ;;
    "qt" | "qtconsole")
        go "-d" "$CONDAPATH/jupyter-qtconsole --kernel julia-0.6"
        ;;
    "jupyter")
        ARGS="--allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        go "-d -p 8888:8888" "$CONDAPATH/jupyter notebook $ARGS"
        ;;
    "build")
        tarball TARBALL
        vsn VSN $TARBALL
        BUILDARG="--build-arg JULIA_TARBALL=$TARBALL"
        docker build --rm $BUILDARG -t julia:$VSN $(dirname $0)
        ;;
    *)
        err "unrecognized command: $1"
esac

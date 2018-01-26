#!/usr/bin/env bash

set -e

function err() {
    echo "$1"
    exit 1
}

usage() {
    echo "manage julia container. latest julia + jupyter, CSV, and plotting."
    echo ""
    echo "$0 help - this text"
    echo "$0 bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "$0 julia [DIR] - start a julia repl, mount host DIR to container CWD"
    echo "$0 qt [DIR] - start qtconsole, mount host DIR as container CWD"
    echo "$0 notebook [DIR] - start jupyter on port 8888, mount host DIR"
    echo "$0 build - build docker image from latest julia"
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
            xhost +127.0.0.1
            defaults org.macosforge.xquartz.X11 app_to_run /usr/bin/true
            defaults org.macosforge.xquartz.X11 no_auth 1
            defaults org.macosforge.xquartz.X11 nolisten_tcp 0
            ps -ef | grep -q "bin/Xquart[z]" || open -Fga Xquartz.app
            ;;
        "Linux")
            ;;
    esac
}

function xconf() {
    local r
    case "$(uname)" in
        "Darwin")
            r="-e DISPLAY=docker.for.mac.host.internal:0 \
               -v /tmp/.X11-unix:/tmp/.X11-unix"
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
    local USERFLAGS="$1"
    local CMD="$2"
    local VOL="${3:-/tmp/julia}"
    local FLAGS="--detach-keys ctrl-q,ctrl-q --rm -v ${VOL}:/opt/julia/tmp"
    check docker
    check_X
    tag TAG
    xconf XCONF
    echo "found julia:$TAG"
    echo "mounting $VOL"
    docker run $FLAGS $USERFLAGS $XCONF julia:$TAG $CMD
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
    echo "julia version is $r"
    eval $1="'$r'";
}

case "$1" in
    "" | "help" )
        usage
        ;;
    "shell" | "bash")
        go "-it" "/bin/bash" "$2"
        ;;
    "julia" | "repl")
        go "-it" "julia" "$2"
        ;;
    "qt" | "qtconsole")
        go "-d" "jupyter-qtconsole --kernel julia-0.6" "$2"
        ;;
    "notebook" | "jupyter")
        AS="--allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        go "-d -p 8888:8888" "jupyter notebook $AS" "$2"
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

#!/bin/bash

function err() {
    echo "$1"
    exit 1
}

function ip () {
    ifconfig | grep 'inet '| awk '{print $2}' | grep -v 127.0.0.1 | head -1
}

function go() {
    case "$(uname)" in
        "Darwin")
            $(type docker &>/dev/null) || err "no docker"
            $(type Xquartz &>/dev/null) || err "no X"
            $(ps -ef | grep -q "bin/Xquart[z]") || open -Fga Xquartz.app
            docker run $1 --rm --net=host \
                   -e XAUTHORITY=/tmp/xauth \
                   -e DISPLAY=$(ip):0 \
                   -v ~/.Xauthority:/tmp/xauth \
                   qtconsole:0.6.1 \
                   $2
            ;;
        "Linux")
            $(type docker &>/dev/null) || err "no docker"
            docker run $1 --rm --net=host \
                   -v /tmp/.X11-unix:/tmp/.X11-unix \
                   -e DISPLAY=unix$DISPLAY \
                   qtconsole:0.6.1 \
                   $2
            ;;
        *)
            err "Unknown OS"
    esac
}

case "$1" in
    "shell" | "bash")
        go "-it" "/bin/bash"
        ;;
    "julia" | "repl")
        go "-it" "/opt/julia/bin/julia"
        ;;
    "" | "run")
        go "-d" ""
        ;;
    "build")
        docker build --rm -t qtconsole:0.6.1 $(dirname $0)
        ;;
    *)
        err "unrecognized command: $1"
esac

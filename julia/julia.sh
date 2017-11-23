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
            docker run $1 --rm \
                   -p 8888:8888 \
                   -e XAUTHORITY=/tmp/xauth \
                   -e DISPLAY=$(ip):0 \
                   -v /tmp/julia:/home/julia \
                   -v ~/.Xauthority:/tmp/xauth \
                   julia:0.6.1 \
                   $2
            ;;
        "Linux")
            $(type docker &>/dev/null) || err "no docker"
            docker run $1 --rm --net=host \
                   -p 8888:8888 \
                   -v /tmp/.X11-unix:/tmp/.X11-unix \
                   -e DISPLAY=unix$DISPLAY \
                   -v /tmp/julia:/home/julia \
                   julia:0.6.1 \
                   $2
            ;;
        *)
            err "Unknown OS"
    esac
}

CONDAPATH="/root/.julia/v0.6/Conda/deps/usr/bin"

case "$1" in
    "shell" | "bash")
        go "-it" "/bin/bash"
        ;;
    "julia" | "repl")
        go "-it" "/opt/julia/bin/julia"
        ;;
    "" | "qtconsole")
        go "-d" ""
        ;;
    "jupyter")
        go "-d" "$CONDAPATH/jupyter notebook --allow-root --no-browser --ip=0.0.0.0  --NotebookApp.token=''"
        ;;
    "build")
        docker build --rm -t julia:0.6.1 $(dirname $0)
        ;;
    *)
        err "unrecognized command: $1"
esac

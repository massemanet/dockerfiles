#!/bin/bash

if [ -z "$1" ]; then
    CMD=run
else
    CMD="$1"
fi

case "$CMD" in
    "run")
        docker run -d --rm -p 8888:8888 -v /tmp/jupyter:/home/jupyter jupyter:0.6.1
        ;;
    "build")
        docker build --rm -t jupyter:0.6.1 $(dirname $0)
        ;;
    *)
        echo "unrecognized command: $CMD"
esac

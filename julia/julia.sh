#!/bin/bash

if [ -z "$1" ]; then
    CMD=run
else
    CMD="$1"
fi

case "$CMD" in
    "run")
        docker run -it --rm -v /tmp/julia:/home/julia julia:0.6.1
        ;;
    "build")
        docker build --rm -t julia:0.6.1 $(dirname $0)
        ;;
    *)
        echo "unrecognized command: $CMD"
esac

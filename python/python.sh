#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname $0)/../helpers.sh"

usage() {
    echo "manage python container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- build - build docker image from latest python"
    exit 0
}

function vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("dpkg-query" "-l" "python3")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+")"
    eval "$1='$r'"
}

CMD="${1:-bash}"
VOL="${2:-/tmp/python}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go python "-it" "/bin/bash" "$VOL"
        ;;
    "atom")
        go python "-d" "atom" "$VOL"
        ;;
    "pycharm")
        go python "-d" "pycharm.sh" "$VOL"
        ;;
    "notebook" | "jupyter")
        AS="--allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        go python "-d -p 8888:8888" "jupyter notebook $AS" "$VOL"
        ;;
    "build")
        build IMAGE
        vsn VSN "$IMAGE"
        tag "$IMAGE" "python:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

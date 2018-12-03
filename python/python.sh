#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname "$0")/../helpers.sh"

THIS="$(basename "$0" ".sh")"

usage() {
    echo "manage $THIS container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- build - build docker image from latest $THIS"
    exit 0
}

vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("dpkg-query" "-l" "python3")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+")"
    eval "$1='$r'"
}

CMD="${1:-bash}"
VOL="${2:-/tmp/$THIS}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go "$THIS" "-it" "/bin/bash" "$VOL"
        ;;
    "atom")
        go "$THIS" "-d" "atom -fw" "$VOL"
        ;;
    "pycharm")
        go "$THIS" "-d" "pycharm.sh" "$VOL"
        ;;
    "notebook" | "jupyter")
        AS="--no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        ID="$(go "$THIS" "-d -p 8888" "jupyter-notebook $AS" "$VOL")"
        NET="$(docker ps --no-trunc | grep "$ID")"
        [ -z "$NET" ] && err "failed to start container"
        echo "$NET" | grep -Eo "[0-9\\.:]+->" | cut -f2 -d":" | cut -f1 -d"-"
        ;;
    "kill" | "die")
        die "$THIS"
        ;;
    "build")
        build IMAGE "base" "18.10"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

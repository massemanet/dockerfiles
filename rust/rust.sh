#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname $0)/../helpers.sh"

usage() {
    echo "manage rust container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- build - build docker image from latest rust"
    exit 0
}

function vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("rustc" "--version")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+")"
    eval "$1='$r'"
}

CMD="${1:-erlang}"
VOL="${2:-/tmp/erlang}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go erlang "-it" "/bin/bash" "$VOL"
        ;;
    "build")
        build IMAGE
        vsn VSN "$IMAGE"
        tag "$IMAGE" "erlang:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

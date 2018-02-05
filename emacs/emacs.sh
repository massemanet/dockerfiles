#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname $0)/../helpers.sh"

usage() {
    echo "manage emacs container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- emacs [DIR] - start GUI emacs, mount host DIR to container CWD"
    echo "- build - build docker image with latest emacs (ubuntu)"
    exit 0
}

function vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("emacs" "--version")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+")"
    eval "$1='$r'"
}

CMD="${1:-emacs}"
VOL="${2:-/tmp/emacs}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go emacs "-it" "/bin/bash" "$VOL"
        ;;
    "emacs")
        go emacs "-d" "emacs" "$VOL"
        ;;
    "build")
        build IMAGE
        vsn VSN "$IMAGE"
        tag "$IMAGE" "emacs:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname "$0")/../helpers.sh"

THIS="$(basename "$0" ".sh")"

usage() {
    echo "manage $THIS (ubuntu) container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- emacs [DIR] - start GUI emacs, mount host DIR to container CWD"
    echo "- build - build docker image with latest emacs (ubuntu)"
    exit 0
}

vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("cat" "/etc/os-release")

    r="$(docker run "$IMAGE" "${C[@]}" | grep N_ID | grep -Eo "[0-9]+\\.[0-9]+")"
    eval "$1='$r'"
}

CMD="${1:-emacs}"
VOL="${2:-/tmp/"$THIS"}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go "$THIS" "-it" "/bin/bash" "$VOL"
        ;;
    "emacs")
        go "$THIS" "-d" "emacs -mm" "$VOL"
        ;;
    "build")
        build IMAGE "ubuntu" "18.10"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

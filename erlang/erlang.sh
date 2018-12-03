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
    echo "- erl [DIR] - start an $THIS repl, mount host DIR to container CWD"
    echo "- build - build docker image from latest $THIS"
    exit 0
}

vsn() {
    local IMAGE="$2"
    local r
    local C=("dpkg-query" "-l" "erlang-dev")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+(\\.[0-9])*")"
    eval "$1='$r'"
}

CMD="${1:-"$THIS"}"
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
    "erl" | "$THIS" | "repl")
        go "$THIS" "-it" "erl" "$VOL"
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

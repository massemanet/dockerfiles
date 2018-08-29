#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname "$0")/../helpers.sh"

usage() {
    echo "manage erlang container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- erl [DIR] - start an erlang repl, mount host DIR to container CWD"
    echo "- build - build docker image from latest erlang"
    exit 0
}

vsn() {
    local IMAGE="$2"
    local r
    local C=("dpkg-query" "-l" "erlang-dev")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+(\\.[0-9])*")"
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
    "emacs")
        go erlang "-d" "emacs -mm" "$VOL"
        ;;
    "erl" | "erlang" | "repl")
        go erlang "-it" "erl" "$VOL"
        ;;
    "kill" | "die")
        die erlang
        ;;
    "build")
        build IMAGE
        vsn VSN "$IMAGE"
        tag "$IMAGE" "erlang:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

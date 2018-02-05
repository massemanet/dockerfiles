#!/usr/bin/env bash

# shellcheck source=../helpers.sh
. "$(dirname $0)/../helpers.sh"

usage() {
    echo "manage erlang container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- erl [DIR] - start an erlang repl, mount host DIR to container CWD"
    echo "- build - build docker image from latest erlang"
    exit 0
}

function vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("dpkg-query" "-l" "erlang-dev")
    r="$(docker run -it "$2" "${C[@]}" | grep -Eo "[0-9]+\\.[0-9]+\\.[0-9]+")"
    eval "$1='$r'"
}

CMD="${1:-help}"
VOL="${2:-/tmp/erlang}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go erlang "-it" "/bin/bash" "$VOL"
        ;;
    "erl" | "erlang" | "repl")
        go erlang "-it" "erl" "$VOL"
        ;;
    "build")
        build IMAGE
        vsn VSN "$IMAGE"
        tag "$IMAGE" "erlang:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

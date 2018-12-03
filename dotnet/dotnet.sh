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
    echo "- fsi [DIR] - start an fsharp repl, mount host DIR to container CWD"
    echo "- build - build docker image from latest fharp .net core"
    exit 0
}

vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("$THIS" "--version")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -Eo "[0-9]\\.[0-9]\\.[0-9]")"
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
    "fsharp" | "fsi" | "repl")
        go "$THIS" "-it" "fsi" "$VOL"
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

#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname $0)/../helpers.sh"

usage() {
    echo "manage dotnet container."
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
    local C=("dotnet" "--version")

    r="$(docker run "$IMAGE" "${C[@]}" | grep -Eo "[0-9]\\.[0-9]\\.[0-9]")"
    eval "$1='$r'"
}

CMD="${1:-bash}"
VOL="${2:-/tmp/dotnet}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go dotnet "-it" "/bin/bash" "$VOL"
        ;;
    "fsharp" | "fsi" | "repl")
        go dotnet "-it" "fsi" "$VOL"
        ;;
    "kill" | "die")
        die dotnet
        ;;
    "build")
        build IMAGE
        vsn VSN "$IMAGE"
        tag "$IMAGE" "dotnet:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

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
    "build")
        SDK_VSN="2.1.300-preview1-008174"
        build IMAGE "SDK_VSN=$SDK_VSN"
        tag "$IMAGE" "dotnet:$SDK_VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

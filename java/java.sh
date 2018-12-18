#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname "$0")/../helpers.sh"
# shellcheck source=../tarballs.sh
. "$(dirname "$0")/../tarballs.sh"

THIS="$(basename "$0" ".sh")"

usage() {
    echo "manage $THIS container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- intellij [DIR] - start intellij, mount host DIR to container CWD"
    echo "- build - build docker image from ubuntu 17.10"
    exit 0
}

vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("javac" "--version")

    r="$(docker run "$IMAGE" "${C[@]}" | tr "~" "-" )"
    r="$(echo "$r" | grep -oE "[0-9]+.[0-9a-z]+.[0-9]+")"
    eval "$1='$r'"
}

CMD="${1:-intellij}"
VOL="${2:-/tmp/$THIS}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go "$THIS" "-it" "/bin/bash" "$VOL"
        ;;
    "intellij")
        go "$THIS" "-d" "idea.sh" "$VOL"
        ;;
    "kill" | "die")
        die "$THIS"
        ;;
    "build")
        ij_tarball IJ_TARBALL
        build IMAGE "base" "18.10" "INTELLIJ_TARBALL=$IJ_TARBALL"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

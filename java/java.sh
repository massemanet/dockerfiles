#!/usr/bin/env bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname $0)/../helpers.sh"

usage() {
    echo "manage java container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- intellij [DIR] - start intellij, mount host DIR to container CWD"
    echo "- build - build docker image from ubuntu 17.10"
    exit 0
}

tarball() {
    check curl
    local DLPAGE="https://data.services.jetbrains.com"
    DLPAGE+="/products/releases?code=IIU&latest=true&type=eap"
    local RE="https://[^\"]+ideaIU-[0-9\\.]+tar.gz"
    local r

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | sort -u)"
    [ -z "$r" ] && err "no intellij tarball at $DLPAGE."
    echo "found tarball: $r"
    eval "$1='$r'";
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
VOL="${2:-/tmp/java}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go java "-it" "/bin/bash" "$VOL"
        ;;
    "intellij")
        go java "-d" "idea.sh" "$VOL"
        ;;
    "build")
        tarball TARBALL
        build IMAGE "INTELLIJ_TARBALL=$TARBALL"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "java:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

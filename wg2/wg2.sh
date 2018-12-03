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
    echo "- intellij [DIR] - start intellij, mount host DIR to container CWD"
    echo "- emacs [DIR] - start emacs, mount host DIR to container CWD"
    echo "- build - installs java, intellij, erlang, wireshark"
    exit 0
}

tarball() {
    check curl
    check jq
    local DLPAGE="https://data.services.jetbrains.com"
    DLPAGE+="/products/releases?code=IIC&latest=true&type=release"
    local FILTER=".IIC[].downloads.linux.link"
    local r

    r="$(curl -sL "$DLPAGE" | jq -r "$FILTER")"
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
    "emacs")
        go "$THIS" "-d" "emacs -mm" "$VOL"
        ;;
    "kill" | "die")
        die "$THIS"
        ;;
    "build")
        tarball TARBALL
        build IMAGE "base" "18.10" "INTELLIJ_TARBALL=$TARBALL"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

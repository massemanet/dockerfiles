#!/bin/bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname "$0")/../helpers.sh"

usage() {
    echo "manage go container."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- emacs [DIR] - start emacs, mount host DIR to container CWD"
    echo "- build - build docker image from latest go"
    exit 0
}

tarball() {
    local VSN="$2"
    local DLPAGE="https://golang.org/dl"
    local RE="go[0-9]+(\\.[0-9]+(\\.[0-9]+)*)*\\.linux-amd64.tar.gz"
    local r

    check curl
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no go tarball at $DLPAGE."
    echo "found tarball: $r"
    eval "$1=https://dl.google.com/go/'$r'";
}

vsn() {
    local IMAGE="$2"
    local C=("go" "version")
    local r

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+")"
    eval "$1='$r'";
}

CMD="${1:-go}"
VOL="${2:-/tmp/go}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go go "-it" "/bin/bash" "$VOL"
        ;;
    "emacs")
        go go emacs "-d" "emacs -mm" "$VOL"
        ;;
    "kill" | "die")
        die go
        ;;
    "delete")
        delete go
        ;;
    "build")
        tarball TARBALL "${2:-""}"
        build IMAGE "GO_TARBALL=$TARBALL"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "go:$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

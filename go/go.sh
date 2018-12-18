#!/bin/bash

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
    echo "- emacs [DIR] - start emacs, mount host DIR to container CWD"
    echo "- build - build docker image from latest $THIS"
    exit 0
}

vsn() {
    local IMAGE="$2"
    local C=("go" "version")
    local r

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+(\\.[0-9]+)?")"
    eval "$1='$r'";
}

CMD="${1:-go}"
VOL="${2:-/tmp/$THIS}"
case "$CMD" in
    "help")
        usage
        ;;
    "shell" | "bash")
        go "$THIS" "-it" "/bin/bash" "$VOL"
        ;;
    "emacs")
        go "$THIS" emacs "-d" "emacs -mm" "$VOL"
        ;;
    "kill" | "die")
        die "$THIS"
        ;;
    "delete")
        delete "$THIS"
        ;;
    "build")
        go_tarball GO_TARBALL ""
        build IMAGE "base" "18.10" "GO_TARBALL=$GO_TARBALL"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

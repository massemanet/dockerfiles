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
    echo "- emacs [DIR] - start emacs, mount host DIR to container CWD"
    echo "- build - installs java, intellij, erlang, go, wireshark"
    exit 0
}

vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("javac" "-version")

    r="$(2>&1 docker run "$IMAGE" "${C[@]}")"
    r="$(echo "$r" | grep -oE "[0-9]+\\.[0-9a-z]+\\.[0-9]+")"
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
        ij_tarball IJ
        go_tarball GO
        bazel_tarball BZ "0.19"
        build IMAGE "base" "18.10" "INTELLIJ_TARBALL=$IJ GO_TARBALL=$GO BAZEL_TARBALL=$BZ"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

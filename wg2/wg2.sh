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

intellij_tarball() {
    local DLPAGE="https://data.services.jetbrains.com"
    DLPAGE+="/products/releases?code=IIC&latest=true&type=release"
    local FILTER=".IIC[].downloads.linux.link"
    local r

    check curl
    check jq
    r="$(curl -sL "$DLPAGE" | jq -r "$FILTER")"
    [ -z "$r" ] && err "no intellij tarball at $DLPAGE."
    echo "found tarball: $r"
    eval "$1='$r'";
}

go_tarball() {
    local VSN="${2:-}"
    local RELPAGE="https://golang.org/dl"
    local DLPAGE="https://dl.google.com/go"
    local RE="go[0-9]+(\\.[0-9]+(\\.[0-9]+)?)?\\.linux"
    local r

    check curl
    r="$(curl -sL "$RELPAGE" | grep -oE "$RE" | sort -V | grep "$VSN" | tail -n1)"
    [ -z "$r" ] && err "no go tarball at $RELPAGE."
    echo "found tarball: $r"
    r="$DLPAGE/${r}-amd64.tar.gz"
    eval "$1='$r'";
}

bazel_script() {
    local VSN="${2:-}"
    local GH="https://github.com/bazelbuild/bazel/releases"
    local r

    r="$(curl -sSL "$GH" | \
            grep -Eo "download/[.0-9-]+/bazel-[.0-9-]+-installer-linux-x86_64.sh" | \
            grep "$VSN" | \
            sort -Vu | \
            tail -n1)"
    echo "found script $r"
    r="$GH/$r"
    eval "$1='$r'"
}

vsn() {
    local r="0.0.0"
    local IMAGE="$2"
    local C=("javac" "--version")

    r="$(docker run "$IMAGE" "${C[@]}" | tr "~" "-" )"
    r="$(echo "$r" | grep -oE "[0-9]+.[0-9a-z]+.[0-9]+")"
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
        intellij_tarball IJ
        go_tarball GO
        bazel_script BZ "0.19"
        build IMAGE "base" "18.10" "INTELLIJ_TARBALL=$IJ GO_TARBALL=$GO BAZEL_SCRIPT=$BZ"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

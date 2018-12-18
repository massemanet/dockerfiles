#!/bin/bash

set -eu

# shellcheck source=../helpers.sh
. "$(dirname "$0")/../helpers.sh"
# shellcheck source=../tarballs.sh
. "$(dirname "$0")/../tarballs.sh"

THIS="$(basename "$0" ".sh")"

usage() {
    echo "manage $THIS container. latest $THIS + jupyter, CSV, and plotting."
    echo ""
    echo "- help - this text"
    echo "- bash [DIR] - start a shell, mount host DIR to container CWD"
    echo "- $THIS [DIR] - start a $THIS repl, mount host DIR to container CWD"
    echo "- qt [DIR] - start qtconsole, mount host DIR as container CWD"
    echo "- notebook [DIR] - start jupyter on port 8888, mount host DIR"
    echo "- build - build docker image from latest $THIS"
    exit 0
}

vsn() {
    local IMAGE="$2"
    local C=("$THIS" "--version")
    local r

    r="$(docker run "$IMAGE" "${C[@]}" | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+")"
    eval "$1='$r'";
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
    "julia" | "repl")
        go "$THIS" "-it" "$THIS" "$VOL"
        ;;
    "qt" | "qtconsole")
        go "$THIS" "-d" "jupyter-qtconsole --kernel julia" "$VOL"
        ;;
    "notebook" | "jupyter")
        AS="--allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token=''"
        ID="$(go "$THIS" "-d -p 8888" "jupyter notebook $AS" "$VOL")"
        NET="$(docker ps --no-trunc | grep "$ID")"
        [ -z "$NET" ] && err "failed to start container"
        echo "$NET" | grep -Eo "[0-9\\.:]+->" | cut -f2 -d":" | cut -f1 -d"-"
        ;;
    "kill" | "die")
        die "$THIS"
        ;;
    "delete")
        delete "$THIS"
        ;;
    "build")
        julia_tarball TARBALL "${2:-""}"
        build IMAGE "base" "18.10" "JULIA_TARBALL=$TARBALL"
        vsn VSN "$IMAGE"
        tag "$IMAGE" "$THIS" "$VSN"
        ;;
    *)
        err "unrecognized command: $CMD"
esac

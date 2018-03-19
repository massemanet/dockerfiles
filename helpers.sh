#!/bin/bash

set -eu

function err() {
    echo "$1"
    exit 1
}

function check() {
    echo -n "checking $1..."
    type "$1" &>/dev/null || err "fail. please install $1"
    echo " ok"
}

function xconf() {
    local r=""
    case "$(uname)" in
        "Darwin")
            if type Xquartz &> /dev/null; then
                xhost +127.0.0.1
                defaults write org.macosforge.xquartz.X11 app_to_run /usr/bin/true
                defaults write org.macosforge.xquartz.X11 no_auth 1
                defaults write org.macosforge.xquartz.X11 nolisten_tcp 0
                pgrep -q Xquartz || open -Fga Xquartz.app
                r="-e DISPLAY=docker.for.mac.host.internal:0 \
                   -v /tmp/.X11-unix:/tmp/.X11-unix"
            else
                echo "You don't have Xquartz. Disabling X"
            fi
            ;;
        "Linux")
            if [ -n "${DISPLAY:+x}" ]; then
                r="-e DISPLAY=unix$DISPLAY \
                   -v /tmp/.X11-unix:/tmp/.X11-unix"
            else
                echo "You don't have X. SAD!"
            fi
            ;;
    esac
    eval "$1='$r'";
}

function find_image() {
    local r
    local TARGET="$2"
    r=$(docker images | grep -E "^${TARGET}\\s" |\
        awk '{print $2,$3}' | sort -V | tail -1 | cut -f2 -d" ")
    [ -z "$r" ] && err "no $TARGET image, build first."
    eval "$1='$r'";
}

function flags() {
    local r
    local VOL="$2"
    local DETACH="--detach-keys ctrl-q,ctrl-q"
    local WRKDIR="/opt/wrk"
    if uname -a | grep -q 'Microsoft'; then
        VOL="$(sed 's|/mnt/\([a-z]\)|\1:|' <<< "$VOL")"
        r="$DETACH -v \"$VOL\":$WRKDIR"
    else
        r="--rm $DETACH -v \"$VOL\":$WRKDIR"
    fi
    eval "$1='$r'";
}

function go() {
    local TARGET="$1"
    local USERFLAGS="$2"
    local CMD="$3"
    local VOL="$4"
    mkdir -p "$VOL"
    check docker
    find_image IMAGE "$TARGET"
    xconf XFLAGS
    flags FLAGS "$VOL"
    echo "found image $IMAGE"
    echo "mounting $VOL"
    eval docker run "$FLAGS $USERFLAGS $XFLAGS $IMAGE $CMD"
}

function build() {
    local r
    local ARG="${2:-""}"
    local C=() && [ -n "$ARG" ] && C=("--build-arg" "$ARG")

    check docker
    exec 5>&1
    r="$(docker build "${C[@]}" --rm "$(dirname "$0")" | tee >(cat - >&5))"
    exec 5<&-
    r=$(grep -Eo "Successfully built [a-f0-9]+" <<< "$r" | cut -f3 -d" ")
    [ -z "$r" ] && err "build failed"
    eval "$1='$r'"
}

function tag() {
    local IMAGE="$1"
    local TAG="$2"
    echo "tagging $TAG"
    docker tag "$IMAGE" "$TAG"
}

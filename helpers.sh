#!/bin/bash

set -eu

function err() {
    echo "$1"
    exit 1
}

function check() {
    echo -n "checking ${1}..."
    type "$1" &>/dev/null || err "please install $1"
    echo " ok"
}

function check_X() {
    case "$(uname)" in
        "Darwin")
            check Xquartz
            xhost +127.0.0.1
            defaults write org.macosforge.xquartz.X11 app_to_run /usr/bin/true
            defaults write org.macosforge.xquartz.X11 no_auth 1
            defaults write org.macosforge.xquartz.X11 nolisten_tcp 0
            ps -ef | grep -q "bin/Xquart[z]" || open -Fga Xquartz.app
            ;;
        "Linux")
            ;;
    esac
}

function xconf() {
    local r
    case "$(uname)" in
        "Darwin")
            r="-e DISPLAY=docker.for.mac.host.internal:0 \
               -v /tmp/.X11-unix:/tmp/.X11-unix"
            ;;
        "Linux")
            r="-e DISPLAY=unix$DISPLAY \
               -v /tmp/.X11-unix:/tmp/.X11-unix"
            ;;
    esac
    eval $1="'$r'";
}

function find_tag() {
    local r
    local TARGET="$2"
    r=$(docker images | grep $TARGET | awk '{print $2}' | sort -V | tail -1)
    [ -z "$r" ] && err "no $TARGET image, build first."
    eval $1="'$r'";
}

function go() {
    local TAG XCONF
    local TARGET="$1"
    local USERFLAGS="$2"
    local CMD="$3"
    local VOL="$4"
    local FLAGS="--detach-keys ctrl-q,ctrl-q --rm -v ${VOL}:/opt/$TARGET/tmp"
    check docker
    check_X
    find_tag TAG $TARGET
    xconf XCONF
    echo "found $TARGET:$TAG"
    echo "mounting $VOL"
    docker run $FLAGS $USERFLAGS $XCONF $TARGET:$TAG $CMD
}

function image() {
    local r
    local ARGS=${2:-""}
    check docker
    exec 5>&1
    r="$(docker build $ARGS --rm $(dirname $0) | tee >(cat - >&5))"
    exec 5<&-
    r=$(grep -Eo "Successfully built [a-f0-9]+" <<< "$r" | cut -f3 -d" ")
    eval $1="'$r'"
}

function tag() {
    local IMAGE="$1"
    local TAG="$2"
    echo "tagging $TAG"
    docker tag "$IMAGE" "$TAG"
}

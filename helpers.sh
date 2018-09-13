#!/bin/bash

set -eu

err() {
    echo "$1"
    exit 1
}

check() {
    echo -n "checking $1..."
    type "$1" &>/dev/null || err "fail. please install $1"
    echo " ok"
}

xconf() {
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

find_image() {
    local r
    local TARGET="$2"
    r=$(docker images | grep -E "^${TARGET}\\s" |\
        awk '{print $2,$3}' | sort -V | tail -1 | cut -f2 -d" ")
    [ -z "$r" ] && err "no $TARGET image, build first."
    eval "$1='$r'";
}

flags() {
    local r
    local MOUNTS
    local VOL="$2"
    local DETACH="--detach-keys ctrl-q,ctrl-q"
    local WRKDIR="/opt/wrk"

    if uname -a | grep -q 'Microsoft'
    then MOUNTS="-v \"$(sed 's|/mnt/\([a-z]\)|\1:|' <<< "$VOL")\":$WRKDIR"
    else MOUNTS="-v $VOL:$WRKDIR"
    fi

    [ -e ~/.ssh ] && MOUNTS+=" -v ~/.ssh:/tmp/.ssh:ro"

    [ -e ~/.aws ] && MOUNTS+=" -v ~/.aws:/tmp/.aws:ro"

    [ -e ~/.kube ] && MOUNTS+=" -v ~/.kube:/tmp/.kube:ro"

    [ -e ~/.gitconfig ] && MOUNTS+=" -v ~/.gitconfig:/tmp/gitconfig:ro"

    r=" --rm $DETACH $MOUNTS"
    eval "$1='$r'";
}

go() {
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
    eval docker run "-e DOCKER=$TARGET $FLAGS $USERFLAGS $XFLAGS $IMAGE $CMD"
}

find_containers() {
    join \
        <(docker ps | sed 's/ID/IMAGE/g' | awk '{print $2,$1}' | sort -b) \
        <(docker images | awk '{print $3,$1,$2}' | sort -b) | \
        grep "$1" | \
        awk '{print $2}'
}

die() {
    local TARGET="$1"

    for C in $(find_containers "$TARGET"); do
        echo -n "killing... "
        docker kill "$C"
    done
}

delete() {
    local TARGET="$1"

    TAG=$(docker images | grep "$TARGET" | awk '{print $2}')
    if [ -z "$TAG" ]; then
        echo "no such image: $TARGET"
    else
        die "$TARGET"
        docker rmi -f "$TARGET:$VSN"
    fi
}

build() {
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

tag() {
    local IMAGE="$1"
    local TAG="$2"

    [ -z "$TAG" ] && err "no tag info available"
    echo "tagging $TAG"
    docker tag "$IMAGE" "$TAG"
}

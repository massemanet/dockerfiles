#!/bin/bash

set -eu

# global names space FTW
REPO="massemanet"

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

    r=$(docker images | grep -E "^${REPO}/${TARGET}\\s" |\
        awk '{print $2,$3}' | sort -V | tail -1 | cut -f2 -d" ")
    [ -z "$r" ] && err "no $TARGET image, build first."
    eval "$1='$r'";
}

flags() {
    local r
    local f
    local MOUNTS
    local VOL="$2"
    local DETACH="--detach-keys ctrl-q,ctrl-q"
    local WRKDIR="/opt/wrk"
    local SECCOMP="--cap-add SYS_PTRACE"

    if uname -a | grep -q 'Microsoft'
    then MOUNTS="-v \"$(sed 's|/mnt/\([a-z]\)|\1:|' <<< "$VOL")\":$WRKDIR"
    else MOUNTS="-v $VOL:$WRKDIR:cached"
    fi

    # read-write host files
    for f in ~/.awsvault ~/.password-store ~/.vscode
    do [ -e "$f" ] && MOUNTS+=" -v $f:/tmp/$(basename "$f")"
    done

    # read-only host files
    for f in ~/.aws ~/.gitconfig ~/.gnupg ~/.kube ~/.ssh
    do [ -e "$f" ] && MOUNTS+=" -v $f:/tmp/$(basename "$f"):ro"
    done

    r=" --rm $DETACH $MOUNTS $SECCOMP"
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
    local FROM_NAME="$2"
    local FROM_VSN="$3"
    local ARG="${4:-""}"
    local C=() && [ -n "$ARG" ] && C=("--build-arg" "$ARG")
    local TAG_HEAD TAG_LAST TAG_NEW
    local r

    check git
    check docker

# check that we have a base image
    FROM="$(docker images | grep "$FROM_NAME" | grep "$FROM_VSN")"
    [ -z "$FROM" ] && err "no base image ${FROM_NAME}:${FROM_VSN}"
    FROM="$(echo "$FROM" | sort -V | tail -n1 | awk '{print $1 ":" $2}')"
    [ -z "$FROM" ] && err "no base image ${FROM_NAME}:${FROM_VSN}"
    C+=("--build-arg" "FROM_IMAGE=$FROM")
    echo "building from $FROM"

# check that HEAD is tagged
    TAG_HEAD="$(git tag -l --points-at HEAD)"
    TAG_LAST="$(git describe --abbrev=0 HEAD)"
    if [ -z "$TAG_HEAD" ]; then
        TAG_NEW="$(( "$TAG_LAST" + 1 ))"
        echo "HEAD is not tagged. git tag with $TAG_NEW"
        git tag -a -m"$TAG_NEW" "$TAG_NEW"
    fi

    exec 5>&1
    r="$(docker build "${C[@]}" --rm "$(dirname "$0")" | tee >(cat - >&5))"
    exec 5<&-
    r=$(grep -Eo "Successfully built [a-f0-9]+" <<< "$r" | cut -f3 -d" ")
    [ -z "$r" ] && err "build failed"
    eval "$1='$r'"
}

tag() {
    local IMAGE="$1"
    local PKG="$2"
    local VSN="$3"
    local TAG TAG_HEAD
    TAG_HEAD="$(git tag -l --points-at HEAD)"

    [ -z "$TAG_HEAD" ] && err "HEAD not tagged"
    TAG="$REPO/$PKG:$VSN-$TAG_HEAD"
    if [ -z "$PKG" ] || [ -z "$VSN" ]
    then err "bad tag: $TAG"
    fi
    echo "tagging $TAG"
    docker tag "$IMAGE" "$TAG"
}

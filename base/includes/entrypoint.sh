#!/bin/sh

uid=$(stat --format "%u" .)
gid=$(stat --format "%g" .)

echo "cwd has : uid=$uid, gid=$gid"

grep -q ":${gid}:" /etc/group || groupadd -g "$gid" guser
id "$uid" || useradd -s /bin/bash -u "$uid" -g "$gid" -m duser

export XDG_RUNTIME_DIR=/tmp
xpra --bind-tcp=0.0.0.0:14500 \
     -d all \
     --start-via-proxy=no --dbus-proxy=no --notifications=no --dbus-launch=no \
     --notifications=no --pulseaudio=no --video-encoders=none --encoding=rgb \
     --speaker=disabled --microphone=disabled --webcam=no --mdns=no \
     start

name="$(id -un "$uid")"
group="$(id -gn "$gid")"

[ -e /var/run/docker.sock ] && \
    printf "found docker socket\\n" && \
    sudo chown "$name":"$group" /var/run/docker.sock  && \
    printf "docker socket: %s\\n" "$(ls -lF /var/run/docker.sock)"

if [ "$name" != "$(whoami)" ] && [ "$name" != "root" ]; then
    gosu "$name" /opt/includes/rearrange.sh
    exec gosu "$name" "$@"
else
    /opt/includes/rearrange.sh
    exec "$@"
fi

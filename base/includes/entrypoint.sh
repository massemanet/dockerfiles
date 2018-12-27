#!/bin/sh

uid=$(stat --format "%u" .)
gid=$(stat --format "%g" .)

echo "cwd has : uid=$uid, gid=$gid"

grep -q ":${gid}:" /etc/group || groupadd -g "$gid" guser
id "$uid" || useradd -s /bin/bash -u "$uid" -g "$gid" -m duser

#export XDG_RUNTIME_DIR=/tmp
#xpra --bind-tcp=0.0.0.0:14500 \
#     --start-via-proxy=no --dbus-proxy=no --notifications=no --dbus-launch=no \
#     --notifications=no --pulseaudio=no --video-encoders=none --encoding=rgb \
#     --speaker=disabled --microphone=disabled --webcam=no --mdns=no \
#     start :100

[ -e /var/run/docker.sock ] && \
    printf "found docker socket\\n" && \
    sudo chmod a+rw /var/run/docker.sock  && \
    printf "docker socket: %s\\n" "$(ls -lF /var/run/docker.sock)"

MAC="$(dig +retry=0 +timeout=0 +short host.docker.internal)"
[ -n "$MAC" ] \
  && printf "127.0.0.1 loopback\\n%s localhost\\n%s %s\\n" \
       "$MAC" \
       "$(docker inspect "$(hostname)" | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress')" \
       "$(hostname)" | \
     sudo tee /etc/hosts > /dev/null

name="$(id -un "$uid")"
if [ "$name" = "$(whoami)" ]; then
    /opt/includes/rearrange.sh
    exec "$@"
elif [ "$name" = "root" ]; then
    exec "$@"
else
    gosu "$name" /opt/includes/rearrange.sh
    exec gosu "$name" "$@"
fi

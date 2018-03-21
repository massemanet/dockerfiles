#!/bin/bash

uid=$(stat --format "%u" .)
gid=$(stat --format "%g" .)

echo "cwd has : uid=$uid, gid=$gid"

grep -q ":${gid}:" /etc/group || groupadd -g "$gid" guser
id "$uid" &>/dev/null || useradd -s /bin/bash -u "$uid" -g "$gid" -m duser

name="$(id -un "$uid")"

if [ "$name" != "root" ]; then
    echo "$name ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    gosu "$name" /opt/includes/rearrange.sh
    exec gosu "$name" "$@"
else
    /opt/includes/rearrange.sh
    exec "$@"
fi

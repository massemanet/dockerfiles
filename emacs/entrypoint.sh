#!/bin/bash

uid=$(stat --format "%u" .)
gid=$(stat --format "%g" .)

echo "uid=$uid, gid=$gid"

grep -q ":${gid}:" /etc/group || groupadd -g "$gid" guser
id "$uid" &>/dev/null || useradd -s /bin/bash -u "$uid" -g "$gid" -m duser

name="$(id -un "$uid")"

exec gosu "$name" "$@"

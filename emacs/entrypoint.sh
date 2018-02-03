#!/bin/bash

uid=$(ls -ldn | cut -f3 -d" ")
gid=$(ls -ldn | cut -f4 -d" ")

echo "uid=$uid, gid=$gid"

if [ "$uid" != "0" ]; then
    groupadd -g $gid user
    useradd -s /bin/bash -u $uid -g $gid -m user
    echo "added user ($uid:$gid)"
    exec "$@"
else
    exec "$@"
fi

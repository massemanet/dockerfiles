#!/bin/bash

find /root -type d -not -perm -005 -exec chmod +rx {} \;
find /root -type f -not -perm -004 -exec chmod +r  {} \;

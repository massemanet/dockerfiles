#!/bin/bash
# -*- mode: shell-script -*-

# show current branch
function mygitbranch() {
    if type __git_ps1 &> /dev/null ; then
        __git_ps1 | cut -f1 -d")" | cut -f2 -d"("
    else
        2> /dev/null git rev-parse --abbrev-ref HEAD
    fi
}

# find the basename of the dir that contains the current .git
function mygitdir () {
    local D;
    D=$(2> /dev/null git rev-parse --show-toplevel)
    if [ "$D" == ~ ] ; then
        echo "~";
    else
        basename "$D"
    fi
}

function gitcheck() {
    local BRANCH REMOTE
    BRANCH=$(git branch | awk '{print $2}')
    REMOTE=$(git remote)
    git fetch "$REMOTE" && git rev-list HEAD "^$REMOTE/$BRANCH"
}

# show status of all repos under "$1" (deafults to "~/git")
function gitstat () {
    local base stat branch uptodate
    if [ -z "$1" ]; then
        base=~/git;
    else
        base=$1;
    fi;
    for d in "$base"/* ; do
        echo -n "$(basename "$d")"
        echo -n " "
        ( cd "$d" || exit 2
          stat=$(git status)
          branch=$(echo "$stat" | grep -Eo "On branch .*$" | cut -f3 -d" ")
          [ -z "$branch" ] && \
              branch=$(echo "$stat" | \
                           grep -Eo "HEAD detached|Not currently on any" && \
                           echo "!")
          [ -z "$branch" ] && \
              branch="()"
          uptodate="$(echo "$stat" | grep -q "is behind" && echo "!")"
          [ -z "$uptodate" ] && \
              uptodate=$(echo "$stat" | grep -q "is ahead" && echo "*")
          [ -z "$uptodate" ] && \
              uptodate=$(echo "$stat" | grep -q "diverged" && echo "<")
          [ -z "$uptodate" ] && \
              uptodate=$(echo "$stat" | grep -Eq "Change|Untrac" && echo "#")
          echo -n "$branch"
          echo -n "  "
          echo -n "(""$uptodate"")"
          echo -n "  "
          2>/dev/null git describe --tags HEAD )
    done | column -t
}

# update all remotes for all repos under "$1" (defaults to "~/git")
gitupd() {
    local base

    base=${1:-~/git}
    for d in "$base"/*
    do
        echo -n "$(basename "$d")"": "
        (cd "$d" && git fetch --prune 1> /dev/null && git pull)
    done
}
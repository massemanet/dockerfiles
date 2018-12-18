#!/bin/bash

go_tarball() {
    local VSN="${2:-}"
    local RELPAGE="https://golang.org/dl"
    local DLPAGE="https://dl.google.com/go"
    local RE="go[0-9]+(\\.[0-9]+(\\.[0-9]+)?)?\\.linux"
    local r

    check curl
    r="$(curl -sL "$RELPAGE" | grep -oE "$RE" | sort -V | grep "$VSN" | tail -n1)"
    [ -z "$r" ] && err "no go tarball at $RELPAGE."
    echo "found tarball: $r"
    r="$DLPAGE/${r}-amd64.tar.gz"
    eval "$1='$r'";
}

ij_tarball() {
    local DLPAGE="https://data.services.jetbrains.com"
    DLPAGE+="/products/releases?code=IIC&latest=true&type=release"
    local FILTER=".IIC[].downloads.linux.link"
    local r

    check curl
    check jq
    r="$(curl -sL "$DLPAGE" | jq -r "$FILTER")"
    [ -z "$r" ] && err "no intellij tarball at $DLPAGE."
    echo "found tarball: $r"
    eval "$1='$r'";
}

bazel_tarball() {
    local VSN="${2:-}"
    local GH="https://github.com/bazelbuild/bazel/releases"
    local RE="download/[.0-9-]+/bazel-[.0-9-]+-installer-linux-x86_64.sh"
    local r

    check curl
    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found bazel script $r"
    r="$GH/$r"
    eval "$1='$r'"
}

julia_tarball() {
    local VSN="${2:-}"
    local DLPAGE="https://julialang.org/downloads"
    local RE="https://[^\"]+/julia-[0-9\\.]+-linux-x86_64.tar.gz"
    local r

    check curl
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no julia tarball at $DLPAGE."
    echo "found tarball: $r"
    eval "$1='$r'";
}


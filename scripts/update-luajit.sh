#!/usr/bin/env bash
# Vendor an exact upstream LuaJIT commit into deps/luajit.
#
# Usage:
#   scripts/update-luajit.sh          Re-vendor the commit pinned in deps/luajit.commit.
#                                     Verify with: git diff --exit-code deps/
#   scripts/update-luajit.sh <ref>    Vendor a branch, tag or commit (e.g. v2.1) and pin it.
#
# The files come from `git archive`, i.e. the same tree upstream publishes as a
# tarball, so re-running this for the pinned commit must leave no diff.
set -euo pipefail

url=https://github.com/LuaJIT/LuaJIT.git
root=$(git rev-parse --show-toplevel)
dest=$root/deps/luajit
pin=$root/deps/luajit.commit

ref=${1:-$(cat "$pin")}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git -C "$tmp" init -q
git -C "$tmp" fetch -q --depth 1 "$url" "$ref"
commit=$(git -C "$tmp" rev-parse FETCH_HEAD)

rm -rf "$dest"
mkdir -p "$dest"
git -C "$tmp" archive FETCH_HEAD | tar -x -C "$dest"
echo "$commit" > "$pin"

echo "LuaJIT $commit (relver $(cat "$dest/.relver")) vendored into deps/luajit"

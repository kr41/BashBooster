#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

SRC_DIR="$( bb-tmp-dir )"
DST_DIR="$BB_WORKSPACE/testdir"
bb-event-on bb-cleanup 'rm -rf "$DST_DIR"'
bb-event-on dir-changed on-dir-changes
on-dir-changes() {
    echo "Dir changed $1"
}

bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 1
[[ -d "$DST_DIR" ]] || bb-exit 1 "Dir doesn't exist"

touch "$SRC_DIR/foo"
mkdir "$SRC_DIR/bar"
touch "$SRC_DIR/bar/baz"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 2
[[ -f "$DST_DIR/foo" ]] || bb-exit 2 "File 'foo' doesn't exist"
[[ -d "$DST_DIR/bar" ]] || bb-exit 2 "Directory 'bar' doesn't exist"
[[ -f "$DST_DIR/bar/baz" ]] || bb-exit 2 "File 'bar/baz' doesn't exist"

echo "Foo" >> "$SRC_DIR/foo"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 3
[[ -z "$( diff -q "$DST_DIR/foo" "$SRC_DIR/foo" )" ]] || bb-exit 3 "Files 'foo' are different"

rm "$SRC_DIR/foo"
rm -r "$SRC_DIR/bar"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 4
[[ ! -f "$DST_DIR/foo" ]] || bb-exit 4 "File 'foo' still exists"
[[ ! -d "$DST_DIR/bar" ]] || bb-exit 4 "Directory 'bar' still exists"
[[ ! -f "$DST_DIR/bar/baz" ]] || bb-exit 4 "File 'bar/baz' still exists"

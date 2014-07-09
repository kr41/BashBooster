#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='sync-dir'
source ../bashbooster.sh

SRC_DIR=`bb-tmp-dir`
DST_DIR="$BB_WORKSPACE/testdir"
bb-event-listen bb-cleanup 'rm -rf "$DST_DIR"'
bb-event-listen dir-changed-1 'echo "Dir changed 1"'
bb-event-listen dir-changed-2 'echo "Dir changed 2"'
bb-event-listen dir-changed-3 'echo "Dir changed 3"'
bb-event-listen dir-changed-4 'echo "Dir changed 4"'

bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed-1'
[[ -d "$DST_DIR" ]] || bb-die 1 "Dir doesn't exist"

touch "$SRC_DIR/foo"
mkdir "$SRC_DIR/bar"
touch "$SRC_DIR/bar/baz"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed-2'
[[ -f "$DST_DIR/foo" ]] || bb-die 2 "File 'foo' doesn't exist"
[[ -d "$DST_DIR/bar" ]] || bb-die 2 "Directory 'bar' doesn't exist"
[[ -f "$DST_DIR/bar/baz" ]] || bb-die 2 "File 'bar/baz' doesn't exist"

echo "Foo" >> "$SRC_DIR/foo"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed-3'
[[ -z `diff -q "$DST_DIR/foo" "$SRC_DIR/foo"` ]] || bb-die 3 "Files 'foo' are different"

rm "$SRC_DIR/foo"
rm -r "$SRC_DIR/bar"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed-4'
[[ ! -f "$DST_DIR/foo" ]] || bb-die 4 "File 'foo' still exists"
[[ ! -d "$DST_DIR/bar" ]] || bb-die 4 "Directory 'bar' still exists"
[[ ! -f "$DST_DIR/bar/baz" ]] || bb-die 4 "File 'bar/baz' still exists"

#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

SRC_DIR="$( bb-tmp-dir )"
DST_DIR="$BB_WORKSPACE/testdir"

bb-event-on bb-cleanup 'rm -rf "$DST_DIR"'

# Mock
EXPECT_EVENT='dir-changed'
EXPECT_PARAM=0
bb-event-delay() {
    local EVENT="$1"
    local PARAM="$2"
    bb-assert '[[ "$EVENT" == "$EXPECT_EVENT" ]]'
    bb-assert '[[ "$PARAM" == "$EXPECT_PARAM" ]]'
}


EXPECT_PARAM=1
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 1
bb-assert '[[ -d "$DST_DIR" ]]'

EXPECT_PARAM=2
touch "$SRC_DIR/foo"
mkdir "$SRC_DIR/bar"
touch "$SRC_DIR/bar/baz"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 2
bb-assert '[[ -f "$DST_DIR/foo" ]]'
bb-assert '[[ -d "$DST_DIR/bar" ]]'
bb-assert '[[ -f "$DST_DIR/bar/baz" ]]'

EXPECT_PARAM=3
echo "Foo" >> "$SRC_DIR/foo"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 3
bb-assert '[[ -z "$( diff -q "$DST_DIR/foo" "$SRC_DIR/foo" )" ]]'

EXPECT_PARAM=4
rm "$SRC_DIR/foo"
rm -r "$SRC_DIR/bar"
bb-sync-dir "$DST_DIR" "$SRC_DIR" 'dir-changed' 4
bb-assert '[[ ! -f "$DST_DIR/foo" ]]'
bb-assert '[[ ! -d "$DST_DIR/bar" ]]'
bb-assert '[[ ! -f "$DST_DIR/bar/baz" ]]'

bb-sync-dir "$DST_DIR" "$SRC_DIR" 'event-should-not-be-delayed'

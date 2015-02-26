#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_LEVEL=$BB_LOG_DEBUG
source "$BASHBOOSTER"

SRC_FILE="$( bb-tmp-file )"
DST_FILE="$BB_WORKSPACE/testfile"

bb-event-on bb-cleanup 'rm -f "$DST_FILE"'

# Mock
EXPECT_EVENT='file-changed'
EXPECT_PARAM=0
bb-event-delay() {
    local EVENT="$1"
    local PARAM="$2"
    bb-assert '[[ "$EVENT" == "$EXPECT_EVENT" ]]'
    bb-assert '[[ "$PARAM" == "$EXPECT_PARAM" ]]'
}


EXPECT_PARAM=1
echo "Foo" >> "$SRC_FILE"
bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed' 1
bb-assert '[[ -f "$DST_FILE" ]]'
bb-assert '[[ ! -n "$( diff -q "$DST_FILE" "$SRC_FILE" )" ]]'

EXPECT_PARAM=2
echo "Bar" >> "$SRC_FILE"
bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed' 2
bb-assert '[[ ! -n "$( diff -q "$DST_FILE" "$SRC_FILE" )" ]]'

bb-sync-file "$DST_FILE" "$SRC_FILE" 'event-should-not-be-delayed'

#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../bashbooster.sh

SRC_FILE=`bb-tmp-file`
DST_FILE="$BB_WORKSPACE/testfile"
bb-event-listen file-changed 'echo "File changed"'

echo "Foo" >> "$SRC_FILE"
bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed'
[[ ! -f "$DST_FILE" ]] && bb-die 1 "File doesn't exist"
[[ -n `diff -q $DST_FILE $SRC_FILE` ]] && bb-die 2 "Files are different"

echo "Bar" >> "$SRC_FILE"
bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed'
[[ -n `diff -q $DST_FILE $SRC_FILE` ]] && bb-die 2 "Files are different"

bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed'

#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_LEVEL=$BB_LOG_DEBUG
source ../../bashbooster.sh

SRC_FILE="$( bb-tmp-file )"
DST_FILE="$BB_WORKSPACE/testfile"
bb-event-on bb-cleanup 'rm "$DST_FILE"'
bb-event-on file-changed on-file-changes
on-file-changes() {
    echo "File changed $1"
}

echo "Foo" >> "$SRC_FILE"
bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed' 1
[[ -f "$DST_FILE" ]] || bb-exit 1 "File doesn't exist"
[[ ! -n "$( diff -q "$DST_FILE" "$SRC_FILE" )" ]] || bb-exit 2 "Files are different"

echo "Bar" >> "$SRC_FILE"
bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed' 2
[[ ! -n "$( diff -q "$DST_FILE" "$SRC_FILE" )" ]] || bb-exit 2 "Files are different"

bb-sync-file "$DST_FILE" "$SRC_FILE" 'file-changed' 3

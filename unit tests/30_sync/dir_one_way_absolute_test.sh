#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

SRC_DIR="$BB_WORKSPACE/scr_dir"
DST_DIR="$BB_WORKSPACE/dst_dir"

bb-event-on bb-cleanup 'rm -rf "$DST_DIR"; rm -rf "$SRC_DIR"'

source "dir_one_way.sh"

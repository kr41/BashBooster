#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

timeout 5 wget -q --spider http://bashbooster.net/index.html
[ $? -eq 0 ] || exit 255 # Skip test (No internet access?)

mkdir -p "$BB_DOWNLOAD_DIR"
touch "$BB_DOWNLOAD_DIR/index.html"
bb-assert '[[ "$( cat "$BB_DOWNLOAD_DIR/index.html" )" == "" ]]'

FILE="$( bb-download 'http://bashbooster.net/index.html' 'index.html' true )"
bb-exit-on-error "Failed"
bb-assert 'cat "$FILE" | grep -q "Bash Booster"'
bb-assert '[[ "$FILE" == "$BB_DOWNLOAD_DIR/index.html" ]]'

bb-download-clean

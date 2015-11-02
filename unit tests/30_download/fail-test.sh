#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

timeout 5 wget -q --spider http://bashbooster.net/index.html
[ $? -eq 0 ] || exit 255 # Skip test (No internet access?)

# expect: STDERR='\[ERROR\] An error occurs while downloading http://localhost:666/file.txt'

FILE="$( bb-download 'http://localhost:666/file.txt' )"

bb-assert '[[ -f "$FILE" ]]'
bb-assert '[[ "$( cat "$FILE" )" == "" ]]'

bb-download-clean

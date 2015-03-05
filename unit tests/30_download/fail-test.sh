#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

# expect: STDERR='\[ERROR\] An error occurs while downloading http://localhost:666/file.txt'

FILE="$( bb-download 'http://localhost:666/file.txt' )"

bb-assert '[[ -f "$FILE" ]]'
bb-assert '[[ "$( cat "$FILE" )" == "" ]]'

bb-download-clean

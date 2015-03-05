#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

# expect: STDERR='\[ERROR\] Unable to get http://localhost:666/file.txt'

FILE1="$( bb-download 'http://localhost:666/file.txt' )"

bb-assert '[[ ! -f "$FILE1" ]]'

bb-download-clean

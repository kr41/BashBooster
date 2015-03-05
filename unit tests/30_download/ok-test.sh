#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

FILE1="$( bb-download 'http://bashbooster.net/index.html' )"
bb-exit-on-error "Failed"
bb-assert 'cat "$FILE1" | grep -q "Bash Booster"'

FILE2="$( bb-download 'http://bashbooster.net/index.html' )"
bb-exit-on-error "Failed"
bb-assert 'cat "$FILE2" | grep -q "Bash Booster"'
bb-assert '[[ "$FILE1" == "$FILE2" ]]'

bb-download-clean

#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

FILE="$( bb-tmp-file )"
bb-assert '[[ -f "$FILE" ]]'

DIR="$( bb-tmp-dir )"
bb-assert '[[ -d "$DIR" ]]'

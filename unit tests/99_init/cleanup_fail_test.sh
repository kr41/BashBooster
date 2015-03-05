#!/usr/bin/env bash

# expect: CODE=1

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

false

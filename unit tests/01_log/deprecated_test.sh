#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"


EXPECTED_MESSAGE=""
# Mock
bb-log-warning() {
    MESSAGE="$1"
    bb-assert '[[ "$MESSAGE" == "$EXPECTED_MESSAGE" ]]'
}


old-func-1() {
    bb-log-deprecated 'new-func-1'
}

old-func-2() {
    bb-log-deprecated 'new-func-2' 'old-func-2'
}

EXPECTED_MESSAGE="'old-func-1' is deprecated, use 'new-func-1' instead"
old-func-1

EXPECTED_MESSAGE="'old-func-2' is deprecated, use 'new-func-2' instead"
old-func-2

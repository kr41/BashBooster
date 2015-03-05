#!/usr/bin/env bash

# expect: CODE=1
# expect: STDERR='\[ERROR\] func-2 failed'

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

func-1() {
    return 0
}

func-2() {
    return 1
}

func-1
bb-exit-on-error 'func-1 failed'

func-2
bb-exit-on-error 'func-2 failed'

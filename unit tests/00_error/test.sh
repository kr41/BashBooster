#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

CALL_ORDER=''

func-1() {
    return 0
}
func-2() {
    return 1
}

func-1
if bb-error?
then
    CALL_ORDER="${CALL_ORDER}1"
fi

func-2
if bb-error?
then
    bb-assert '(( $BB_ERROR == 1 ))'
    CALL_ORDER="${CALL_ORDER}2"
fi


bb-assert '[[ "$CALL_ORDER" == "2" ]]'

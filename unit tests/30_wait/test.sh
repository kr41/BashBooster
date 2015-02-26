#!/usr/bin/env bash


unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"


COUNTER=3
starting-process-mock() {
    COUNTER=$(( $COUNTER - 1 ))
    return $COUNTER
}

# Mock
sleep() {
    return
}

bb-wait 'starting-process-mock'
bb-assert '(( $COUNTER == 0 ))'


# expect: STDERR="\[ERROR\] Timeout has been reached during wait for 'starting-process-mock'"
COUNTER=3
bb-wait 'starting-process-mock' 0
CODE=$?
bb-assert '(( $CODE == 1 ))'
bb-assert '(( $COUNTER > 0 ))'

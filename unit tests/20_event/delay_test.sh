#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

# expect: STDOUT="first third second"

bb-event-delay first
bb-event-delay first

CALL_ORDER=""

first() {
    CALL_ORDER="$CALL_ORDER first"
    bb-event-delay second
}

second() {
    CALL_ORDER="$CALL_ORDER second"
    echo "$CALL_ORDER"
}

third() {
    CALL_ORDER="$CALL_ORDER third"
}



bb-event-on first first
bb-event-on second second
bb-event-on third third

bb-event-delay third

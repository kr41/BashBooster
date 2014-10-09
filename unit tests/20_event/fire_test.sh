#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

FIRED=0
handler() {
    FIRED=$(( $FIRED + 1 ))
}

bb-event-fire event
bb-assert '(( $FIRED == 0 ))'

bb-event-on event handler
bb-event-on event handler
bb-event-fire event
bb-assert '(( $FIRED == 1 ))'

bb-event-off event handler
bb-event-fire event
bb-assert '(( $FIRED == 1 ))'

#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

handler() {
    local PARAM1="$1"
    local PARAM2="$2"
    bb-log-info "Handler called"
    bb-log-info "PARAM1=$PARAM1"
    bb-log-info "PARAM2=$PARAM2"
}
bb-event-on event handler

bb-event-fire event p1 p2
bb-event-delay event p3 p4

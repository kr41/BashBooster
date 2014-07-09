#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-event'
source ../bashbooster.sh

BB_EVENT_MAX_DEPTH=5

event-handler() {
    echo "Event processed"
    bb-event-delay event
}

bb-event-listen event event-handler
bb-event-delay event

#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-event'
source ../bashbooster.sh

event-handler() {
    echo "Event processed"
}

bb-event-fire event
bb-event-listen event event-handler
bb-event-fire event

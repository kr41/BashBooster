#!/bin/bash

BB_LOG_PREFIX='test-event'
source ../bashbooster.sh

BB_EVENT_MAX_DEPTH=5

event-handler() {
    echo "Event processed"
    bb-event-fire event
}

bb-event-listen event event-handler
bb-event-fire event

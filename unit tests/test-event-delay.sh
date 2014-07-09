#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-event'
source ../bashbooster.sh

bb-event-delay first
bb-event-delay first

first() {
    echo "First Event"
    bb-event-delay second
}

second() {
    echo "Second Event"
}

bb-event-listen first first
bb-event-listen second second

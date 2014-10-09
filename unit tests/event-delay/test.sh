#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

bb-event-delay first
bb-event-delay first

first() {
    echo "First Event"
    bb-event-delay second
}

second() {
    echo "Second Event"
}

bb-event-on first first
bb-event-on second second

bb-event-on event-1 'echo event-1'
bb-event-on event-11 'echo event-11'

bb-event-delay event-11
bb-event-delay event-1

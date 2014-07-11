#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-log'
source ../../bashbooster.sh

first() {
    second "Argument 2"
}

second() {
    bb-log-callstack
}

BB_LOG_LEVEL=$BB_LOG_DEBUG

first "Argument 1"

BB_LOG_LEVEL=$BB_LOG_INFO

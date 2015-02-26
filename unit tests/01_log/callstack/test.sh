#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

# expect: STDERR_FILE="$TEST_DIR/stderr.txt"

BB_LOG_LEVEL='INFO'
source "$BASHBOOSTER"

first() {
    second "Argument 2"
}

second() {
    bb-log-callstack
}

BB_LOG_LEVEL=$BB_LOG_DEBUG

first "Argument 1"

BB_LOG_LEVEL=$BB_LOG_INFO

#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

# expect: STDERR_FILE="$TEST_DIR/stderr.txt"

source ../../../bashbooster.sh

bb-log-info "Message from test.sh"
BB_LOG_LEVEL='INFO'

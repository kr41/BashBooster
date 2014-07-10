#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-log-time'
BB_LOG_USE_TIME=1
source ../../bashbooster.sh

date-mock() {
    echo '2014-07-02 13:26:41+07:00'
}
BB_LOG_TIME='date-mock'
BB_LOG_LEVEL=$BB_LOG_DEBUG

bb-log-debug "Debug message"
bb-log-info "Info message"
bb-log-warning "Warning message"
bb-log-error "Error message"

BB_LOG_LEVEL=$BB_LOG_INFO

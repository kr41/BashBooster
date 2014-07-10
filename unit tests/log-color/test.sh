#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-log-color'
BB_LOG_USE_COLOR=true
source ../../bashbooster.sh

BB_LOG_LEVEL=$BB_LOG_DEBUG

bb-log-debug "Debug message"
bb-log-info "Info message"
bb-log-warning "Warning message"
bb-log-error "Error message"

BB_LOG_LEVEL=$BB_LOG_INFO

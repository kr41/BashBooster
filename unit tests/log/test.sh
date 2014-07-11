#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

BB_LOG_LEVEL=$BB_LOG_DEBUG
bb-log-debug "Debug message 1"
bb-log-info "Info message 1"
bb-log-warning "Warning message 1"
bb-log-error "Error message 1"

BB_LOG_LEVEL=$BB_LOG_INFO
bb-log-debug "Debug message 2"
bb-log-info "Info message 2"
bb-log-warning "Warning message 2"
bb-log-error "Error message 2"

BB_LOG_LEVEL=$BB_LOG_WARNING
bb-log-debug "Debug message 3"
bb-log-info "Info message 3"
bb-log-warning "Warning message 3"
bb-log-error "Error message 3"

BB_LOG_LEVEL=$BB_LOG_ERROR
bb-log-debug "Debug message 4"
bb-log-info "Info message 4"
bb-log-warning "Warning message 4"
bb-log-error "Error message 4"

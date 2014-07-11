#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_LEVEL='DEBUG'
source ../../bashbooster.sh

bb-log-info "Message from test.sh"
BB_LOG_LEVEL='INFO'

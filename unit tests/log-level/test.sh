#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

BB_LOG_LEVEL=1
bb-log-level-name
bb-log-level-code
BB_LOG_LEVEL='DEBUG'
bb-log-level-name
bb-log-level-code

BB_LOG_LEVEL=2
bb-log-level-name
bb-log-level-code
BB_LOG_LEVEL='INFO'
bb-log-level-name
bb-log-level-code

BB_LOG_LEVEL=3
bb-log-level-name
bb-log-level-code
BB_LOG_LEVEL='WARNING'
bb-log-level-name
bb-log-level-code

BB_LOG_LEVEL=4
bb-log-level-name
bb-log-level-code
BB_LOG_LEVEL='ERROR'
bb-log-level-name
bb-log-level-code

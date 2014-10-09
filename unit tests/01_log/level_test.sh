#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

BB_LOG_LEVEL=1
bb-assert '[[ "$( bb-log-level-name )" == "DEBUG" ]]'
bb-assert '((  $( bb-log-level-code )  == 1 ))'
BB_LOG_LEVEL='DEBUG'
bb-assert '[[ "$( bb-log-level-name )" == "DEBUG" ]]'
bb-assert '((  $( bb-log-level-code )  == 1 ))'

BB_LOG_LEVEL=2
bb-assert '[[ "$( bb-log-level-name )" == "INFO" ]]'
bb-assert '((  $( bb-log-level-code )  == 2 ))'
BB_LOG_LEVEL='INFO'
bb-assert '[[ "$( bb-log-level-name )" == "INFO" ]]'
bb-assert '((  $( bb-log-level-code )  == 2 ))'

BB_LOG_LEVEL=3
bb-assert '[[ "$( bb-log-level-name )" == "WARNING" ]]'
bb-assert '((  $( bb-log-level-code )  == 3 ))'
BB_LOG_LEVEL='WARNING'
bb-assert '[[ "$( bb-log-level-name )" == "WARNING" ]]'
bb-assert '((  $( bb-log-level-code )  == 3 ))'

BB_LOG_LEVEL=4
bb-assert '[[ "$( bb-log-level-name )" == "ERROR" ]]'
bb-assert '((  $( bb-log-level-code )  == 4 ))'
BB_LOG_LEVEL='ERROR'
bb-assert '[[ "$( bb-log-level-name )" == "ERROR" ]]'
bb-assert '((  $( bb-log-level-code )  == 4 ))'

#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-die'
source ../../bashbooster.sh

bb-exit 1 "Die!"

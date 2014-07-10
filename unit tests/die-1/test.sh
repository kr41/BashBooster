#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-die'
source ../../bashbooster.sh

bb-die 1 "Die!"

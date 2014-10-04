#!/bin/bash

# expect: CODE=1
# expect: STDERR='\[ERROR\] Die!'

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

bb-exit 1 "Die!"

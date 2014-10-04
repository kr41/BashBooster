#!/bin/bash

# expect: CODE=10

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_WORKSPACE="/unexisted/workspace"
source ../../bashbooster.sh

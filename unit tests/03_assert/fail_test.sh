#!/usr/bin/env bash

# expect: CODE=3
# expect: STDERR="Assertion error 'false'"

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh


bb-assert false

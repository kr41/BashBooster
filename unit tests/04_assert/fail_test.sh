#!/usr/bin/env bash

# expect: CODE=$BB_ERROR_ASSERT_FAILED
# expect: STDERR="Assertion error 'false'"

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"


bb-assert false

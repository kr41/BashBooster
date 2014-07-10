#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-var'
source ../../bashbooster.sh


[[ -z "$BB_TEST_VAR" ]] || bb-die 1 "Variable already exists"

bb-var BB_TEST_VAR 'some value'

[[ "$BB_TEST_VAR" == "some value" ]] || bb-die 1 "Variable doesn't exist"

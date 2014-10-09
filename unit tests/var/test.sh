#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh


[[ -z "$BB_TEST_VAR" ]] || bb-exit 1 "Variable already exists"

bb-var BB_TEST_VAR 'some value'

[[ "$BB_TEST_VAR" == "some value" ]] || bb-exit 1 "Variable doesn't exist"

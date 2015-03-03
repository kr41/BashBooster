#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

BB_TEST_VAR_1='some value'

bb-assert '[[ -n "$BB_TEST_VAR_1" ]]'
bb-assert '[[ -z "$BB_TEST_VAR_2" ]]'

bb-var BB_TEST_VAR_1 'some other value'
bb-var BB_TEST_VAR_2 'some other value'

bb-assert '[[ "$BB_TEST_VAR_1" == "some value" ]]'
bb-assert '[[ "$BB_TEST_VAR_2" == "some other value" ]]'

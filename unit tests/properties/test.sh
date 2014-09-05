#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

bb-assert-empty () {
    local ACTUAL="$1"
    local MESSAGE="$2"

    [[ -z "$ACTUAL" ]] || bb-exit 1 "$MESSAGE expected emplty, but was:<$ACTUAL>"
}

bb-assert-equals () {
    local ACTUAL="$1"
    local EXPECTED="$2"
    local MESSAGE="$3"

    [[ "$ACTUAL" == "$EXPECTED" ]] || bb-exit 1 "$MESSAGE expected:<$EXPECTED> but was:<$ACTUAL>"
}

bb-assert-empty "$p_key1"
bb-assert-empty "$p_key2"
bb-assert-empty "$p_key3"
bb-assert-empty "$p_key4"
bb-assert-empty "$p_key5"
bb-assert-empty "$p_long"
bb-assert-empty "$p_tail"
bb-assert-empty "$p_bad_key"
bb-assert-empty "$p_point_key"

bb-properties-read test.properties p_

bb-assert-equals "$p_key1" "value1"
bb-assert-equals "$p_key2" "value2"
bb-assert-equals "$p_key3" "value3"
bb-assert-equals "$p_key4" "value4"
bb-assert-equals "$p_key5" "value5"
bb-assert-equals "$p_long" "string with spaces"
bb-assert-equals "$p_tail" "tail spaces"
bb-assert-equals "$p_bad_key" "good value"
bb-assert-equals "$p_point_key" "a value"

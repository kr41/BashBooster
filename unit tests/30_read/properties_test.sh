#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh


bb-assert '[[ -z "$p_key1" ]]'
bb-assert '[[ -z "$p_key2" ]]'
bb-assert '[[ -z "$p_key3" ]]'
bb-assert '[[ -z "$p_key4" ]]'
bb-assert '[[ -z "$p_key5" ]]'
bb-assert '[[ -z "$p_long" ]]'
bb-assert '[[ -z "$p_tail" ]]'
bb-assert '[[ -z "$p_bad_key" ]]'
bb-assert '[[ -z "$p_point_key" ]]'

bb-read-properties test.properties p_

bb-assert '[[ "$p_key1" == "value1" ]]'
bb-assert '[[ "$p_key2" == "value2" ]]'
bb-assert '[[ "$p_key3" == "value3" ]]'
bb-assert '[[ "$p_key4" == "value4" ]]'
bb-assert '[[ "$p_key5" == "value5" ]]'
bb-assert '[[ "$p_long" == "string with spaces" ]]'
bb-assert '[[ "$p_tail" == "tail spaces" ]]'
bb-assert '[[ "$p_bad_key" == "good value" ]]'
bb-assert '[[ "$p_point_key" == "a value" ]]'

# expect: STDERR="\[ERROR\] 'bad.file' is not readable"
bb-assert '! bb-read-properties bad.file'

bb-assert '[[ -z  "$key1" ]]'
bb-assert '[[ -z  "$key2" ]]'
bb-assert '[[ -z  "$key3" ]]'
bb-assert '[[ -z  "$key4" ]]'
bb-assert '[[ -z  "$key5" ]]'
bb-assert '[[ -z  "$long" ]]'
bb-assert '[[ -z  "$tail" ]]'
bb-assert '[[ -z  "$bad_key" ]]'
bb-assert '[[ -z  "$point_key" ]]'

bb-read-properties test.properties

bb-assert '[[ "$key1" == "value1" ]]'
bb-assert '[[ "$key2" == "value2" ]]'
bb-assert '[[ "$key3" == "value3" ]]'
bb-assert '[[ "$key4" == "value4" ]]'
bb-assert '[[ "$key5" == "value5" ]]'
bb-assert '[[ "$long" == "string with spaces" ]]'
bb-assert '[[ "$tail" == "tail spaces" ]]'
bb-assert '[[ "$bad_key" == "good value" ]]'
bb-assert '[[ "$point_key" == "a value" ]]'

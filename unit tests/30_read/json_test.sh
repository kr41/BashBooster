#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"


bb-assert '[[ -z "$json_key" ]]'
bb-assert '[[ -z "$json_dotted_key" ]]'
bb-assert '[[ -z "$json_object_key" ]]'
bb-assert '[[ -z "$json_object_bad_key" ]]'
bb-assert '[[ -z "$json_array_len" ]]'
bb-assert '[[ -z "$json_array_0" ]]'
bb-assert '[[ -z "$json_array_1" ]]'
bb-assert '[[ -z "$json_array_2" ]]'
bb-assert '[[ -z "$json_array_of_objects_len" ]]'
bb-assert '[[ -z "$json_array_of_objects_0_key" ]]'

bb-read-json 'test.json' 'json'

bb-assert '[[ "$json_key" == "value" ]]'
bb-assert '[[ "$json_dotted_key" == "another value" ]]'
bb-assert '[[ "$json_object_key" == "1" ]]'
bb-assert '[[ "$json_object_bad_key" == "2" ]]'
bb-assert '[[ "$json_array_len" == "3" ]]'
bb-assert '[[ "$json_array_0" == "1" ]]'
bb-assert '[[ "$json_array_1" == "2" ]]'
bb-assert '[[ "$json_array_2" == "3" ]]'
bb-assert '[[ "$json_array_of_objects_len" == "1" ]]'
bb-assert '[[ "$json_array_of_objects_0_key" == "value" ]]'


# _expect: STDERR="\[ERROR\] 'bad.file' is not readable"
bb-assert '! bb-read-json bad.file'

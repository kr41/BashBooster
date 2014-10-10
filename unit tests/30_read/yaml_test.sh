#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh


bb-assert '[[ -z "$yaml_key" ]]'
bb-assert '[[ -z "$yaml_dotted_key" ]]'
bb-assert '[[ -z "$yaml_object_key" ]]'
bb-assert '[[ -z "$yaml_object_bad_key" ]]'
bb-assert '[[ -z "$yaml_array_len" ]]'
bb-assert '[[ -z "$yaml_array_0" ]]'
bb-assert '[[ -z "$yaml_array_1" ]]'
bb-assert '[[ -z "$yaml_array_2" ]]'
bb-assert '[[ -z "$yaml_array_of_objects_len" ]]'
bb-assert '[[ -z "$yaml_array_of_objects_0_key" ]]'

bb-read-yaml 'test.yaml' 'yaml'

bb-assert '[[ "$yaml_key" == "value" ]]'
bb-assert '[[ "$yaml_dotted_key" == "another value" ]]'
bb-assert '[[ "$yaml_object_key" == "1" ]]'
bb-assert '[[ "$yaml_object_bad_key" == "2" ]]'
bb-assert '[[ "$yaml_array_len" == "3" ]]'
bb-assert '[[ "$yaml_array_0" == "1" ]]'
bb-assert '[[ "$yaml_array_1" == "2" ]]'
bb-assert '[[ "$yaml_array_2" == "3" ]]'
bb-assert '[[ "$yaml_array_of_objects_len" == "1" ]]'
bb-assert '[[ "$yaml_array_of_objects_0_key" == "value" ]]'


# _expect: STDERR="\[ERROR\] 'bad.file' is not readable"
bb-assert '! bb-read-yaml bad.file'

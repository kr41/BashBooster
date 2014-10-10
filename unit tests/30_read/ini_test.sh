#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh


bb-assert '[[ -z "$ini_section_key" ]]'
bb-assert '[[ -z "$ini_section_dotted_key" ]]'
bb-assert '[[ -z "$ini_dotted_section_key" ]]'
bb-assert '[[ -z "$ini_dotted_section_bad_key" ]]'

bb-read-ini 'test.ini' '*' 'ini_'

bb-assert '[[ "$ini_section_key" == "value" ]]'
bb-assert '[[ "$ini_section_dotted_key" == "another value" ]]'
bb-assert '[[ "$ini_dotted_section_key" == "1" ]]'
bb-assert '[[ "$ini_dotted_section_bad_key" == "2" ]]'

bb-read-ini 'test.ini' '' 'i_'

bb-assert '[[ "$i_section_key" == "value" ]]'
bb-assert '[[ "$i_section_dotted_key" == "another value" ]]'
bb-assert '[[ "$i_dotted_section_key" == "1" ]]'
bb-assert '[[ "$i_dotted_section_bad_key" == "2" ]]'

# _expect: STDERR="\[ERROR\] 'bad.file' is not readable"
bb-assert '! bb-read-ini bad.file'

bb-assert '[[ -z "$section_key" ]]'
bb-assert '[[ -z "$section_dotted_key" ]]'
bb-assert '[[ -z "$dotted_section_key" ]]'
bb-assert '[[ -z "$dotted_section_bad_key" ]]'

bb-read-ini 'test.ini' 'section'

bb-assert '[[ "$section_key" == "value" ]]'
bb-assert '[[ "$section_dotted_key" == "another value" ]]'
bb-assert '[[ -z "$dotted_section_key" ]]'
bb-assert '[[ -z "$dotted_section_bad_key" ]]'

bb-read-ini 'test.ini' 'dotted.section'

bb-assert '[[ "$dotted_section_key" == "1" ]]'
bb-assert '[[ "$dotted_section_bad_key" == "2" ]]'

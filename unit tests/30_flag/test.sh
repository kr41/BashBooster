#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-flag-clean
bb-assert "! bb-flag? 'flag'"

bb-flag-set 'flag'
bb-assert "bb-flag? 'flag'"

bb-flag-unset 'flag'
bb-assert "! bb-flag? 'flag'"

bb-flag-set 'flag'
bb-assert '[[ -d "$BB_FLAG_DIR" ]]'

bb-flag-clean
bb-assert '[[ ! -d "$BB_FLAG_DIR" ]]'

#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

if [[ ! -d "$BB_FLAG_DIR" ]]
then
    # First run only
    bb-flag-set 'flag'
fi

bb-flag? 'flag'

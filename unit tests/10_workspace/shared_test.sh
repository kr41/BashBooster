#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

TEMP_FILE="$( bb-tmp-file )"

chmod a+x other.sh
./other.sh

# Shared workspace exists, while last script is working
bb-assert '[[ -d "$BB_WORKSPACE" ]]'
bb-assert '[[ -d ".bb-workspace" ]]'
bb-assert '[[ -f "$TEMP_FILE" ]]'

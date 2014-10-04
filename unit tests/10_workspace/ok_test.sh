#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

bb-assert '[[ -d "$BB_WORKSPACE" ]]'
bb-assert '[[ -d ".bb-workspace" ]]'

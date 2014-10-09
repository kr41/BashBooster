#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

[[ -d "$BB_WORKSPACE" ]] || die 1 "Workspace doesn't exist"
[[ -d ".bb-workspace" ]] || die 2 "Invalid workspace location"

#!/usr/bin/env bash

# expect: CODE=10

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_WORKSPACE="/nonexistent/workspace"
source ../../bashbooster.sh

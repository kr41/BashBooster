#!/usr/bin/env bash

# expect: CODE=$BB_ERROR_WORKSPACE_CREATION_FAILED

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_WORKSPACE="/nonexistent/workspace"
source "$BASHBOOSTER"

#!/usr/bin/env bash


unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"


bb-assert 'bb-exe? bash'
bb-assert '! bb-exe? nonexistent-command'

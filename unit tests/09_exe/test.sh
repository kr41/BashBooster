#!/usr/bin/env bash


unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh


bb-assert 'bb-exe? bash'
bb-assert '! bb-exe? nonexistent-command'

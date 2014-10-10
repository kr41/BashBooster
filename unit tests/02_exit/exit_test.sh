#!/usr/bin/env bash

# expect: STDERR='\[INFO\] Exit'

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

bb-exit 0 "Exit"

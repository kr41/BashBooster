#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

FOO=1
BAR='Some Value'
BAZ='One Two Three'

bb-template "template.bbt"

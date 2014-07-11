#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

bb-flag? 'flag' || bb-log-info "Flag is not set"
bb-flag-set 'flag'
bb-flag? 'flag' && bb-log-info "Flag is set"
bb-flag-unset 'flag'
bb-flag? 'flag' || bb-log-info "Flag is not set"
bb-flag-set 'flag'
bb-flag-clean

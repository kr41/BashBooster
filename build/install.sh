#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_USE_COLOR=true
source bashbooster.sh

if (( $UID != 0 ))
then
    bb-exit 1 "This script should be run with root privileges"
fi

CONF_PATH='/etc/bashbooster'
LIB_PATH='/usr/local/lib/bashbooster'
BIN_PATH='/usr/local/bin'

[[ ! -d "$CONF_PATH" ]] && mkdir "$CONF_PATH"
[[ ! -d "$LIB_PATH" ]] && mkdir "$LIB_PATH"

cp bashbooster.sh "$LIB_PATH"
cp bbrc "$CONF_PATH"
cp bb-task "$BIN_PATH"

chmod a+x "$BIN_PATH/bb-task"

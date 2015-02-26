#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

./build.sh

BB_LOG_USE_COLOR=true
source dist/bashbooster.sh

if (( $UID != 0 ))
then
    bb-exit 1 "This script should be run with root privileges"
fi

CONF_PATH='/etc/bashbooster'
LIB_PATH='/usr/local/lib/bashbooster'
BIN_PATH='/usr/local/bin'

[[ ! -d "$CONF_PATH" ]] && mkdir "$CONF_PATH"
[[ ! -d "$LIB_PATH" ]] && mkdir "$LIB_PATH"

cp dist/bashbooster.sh "$LIB_PATH"
cp dist/bbrc "$CONF_PATH/bashbooster"
cp dist/bb-task "$BIN_PATH"

chmod a+x "$BIN_PATH/bb-task"

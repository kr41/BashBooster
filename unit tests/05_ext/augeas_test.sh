#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-augeas? || exit 255  #  Augeas is not installed, skip test

TEST_FILE="`pwd`/sshd_config.test"

bb-ext-augeas 'augeas-func' <<EOF
transform Ssh incl "$TEST_FILE"
load
get '/files$TEST_FILE/LogLevel'
EOF

augeas-func

bb-assert '[[ "$( augeas-func )" == "/files$TEST_FILE/LogLevel = INFO" ]]'

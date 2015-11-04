#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-augeas? || exit 255  #  Augeas is not installed, skip test

# Test normal execution

TEST_FILE="`pwd`/sshd_config.test"

bb-ext-augeas 'augeas-func' <<EOF
transform Ssh incl "$TEST_FILE"
load
get '/files$TEST_FILE/LogLevel'
EOF

bb-assert '[[ "$( augeas-func )" == "/files$TEST_FILE/LogLevel = INFO" ]]'

# Test usage of BB_AUGEAS_PARAMS variable

bb-ext-augeas 'augeas-func-2' <<EOF
get '/files$TEST_FILE/LogLevel'
EOF

BB_AUGEAS_PARAMS="-t \"Ssh incl \\\"$TEST_FILE\\\"\""
bb-assert '[[ "$( augeas-func-2 )" == "/files$TEST_FILE/LogLevel = INFO" ]]'

# Test usage of BB_AUGEAS_ROOT variable

bb-ext-augeas 'augeas-func-3' <<EOF
get '/files/etc/ssh/sshd_config/Port'
EOF
TEST_ROOT="$( bb-tmp-dir )"
mkdir -p "$TEST_ROOT/etc/ssh/"
echo "Port 333" > "$TEST_ROOT/etc/ssh/sshd_config"
BB_AUGEAS_ROOT="$TEST_ROOT"

bb-assert '[[ "$( augeas-func-3 )" == "/files/etc/ssh/sshd_config/Port = 333" ]]'

#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-augeas? || exit 255  #  Augeas is not installed, skip test

TRUE=0
FALSE=1

EXISTING_TEST_FILE="`pwd`/sshd_config.test"

# Make sure Augeas can read our test file
BB_AUGEAS_EXTRA_COMMANDS="transform Ssh incl \"$EXISTING_TEST_FILE\"
load"

# Test that an existing setting can be read
TEST_FILE="$EXISTING_TEST_FILE"
TEST_SETTING="LogLevel"
EXPECTED_VALUE="INFO"
VALUE="$(bb-augeas-get "$TEST_FILE" "$TEST_SETTING")"
bb-exit-on-error "Failed"
bb-assert '[[ "$VALUE" == "$EXPECTED_VALUE" ]]'

# Test that reading a non-existing value doesn't return an error
TEST_FILE="$EXISTING_TEST_FILE"
TEST_SETTING="Port"
EXPECTED_VALUE=""
VALUE="$(bb-augeas-get "$TEST_FILE" "$TEST_SETTING")"
bb-exit-on-error "Failed"
bb-assert '[[ "$VALUE" == "$EXPECTED_VALUE" ]]'

# Test that reading a non-existing file returns an error
TEST_FILE="/etc/bad_file"
TEST_SETTING="LogLevel"
EXPECTED_VALUE=""
VALUE="$(bb-augeas-get "$TEST_FILE" "$TEST_SETTING")"
RESULT=$?
bb-assert '[[ "$RESULT" -ne 0 ]]'


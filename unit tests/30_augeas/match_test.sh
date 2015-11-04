#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-augeas? || exit 255  #  Augeas is not installed, skip test

TRUE=0
FALSE=1

TEST_FILE="`pwd`/sshd_config.test"

# Make sure Augeas can read our test file
BB_AUGEAS_EXTRA_COMMANDS="transform Ssh incl \"$TEST_FILE\"
load"

# Test a successfull match
TEST_SETTING="LogLevel"
TEST_VALUE="INFO"
EXPECTED_RESULT=$TRUE
bb-augeas-match? "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE"
RESULT=$?
bb-assert '[[ $RESULT -eq $EXPECTED_RESULT ]]'

# Test an unsuccessfull match
TEST_SETTING="LogLevel"
TEST_VALUE="DEBUG"
EXPECTED_RESULT=$FALSE
bb-augeas-match? "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE"
RESULT=$?
bb-assert '[[ $RESULT -eq $EXPECTED_RESULT ]]'

# Test with an unsupported file
BB_AUGEAS_EXTRA_COMMANDS=
TEST_SETTING="LogLevel"
TEST_VALUE="DEBUG"
EXPECTED_RESULT=$FALSE
bb-augeas-match? "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE"
RESULT=$?
bb-assert '[[ $RESULT -eq $EXPECTED_RESULT ]]'

# Test with an unexisting file
TEST_FILE=/etc/bad_file
TEST_SETTING="LogLevel"
TEST_VALUE="DEBUG"
EXPECTED_RESULT=$FALSE
bb-augeas-match? "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE"
RESULT=$?
bb-assert '[[ $RESULT -eq $EXPECTED_RESULT ]]'


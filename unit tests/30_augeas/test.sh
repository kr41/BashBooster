#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-augeas? || exit 255  #  Augeas is not installed, skip test

TRUE=0
FALSE=1

# Test Augeas path building
TEST_FILE="/etc/ssh/sshd_config"
TEST_SETTING="LogLevel"
EXPECTED_AUG_PATH="/files$TEST_FILE/$TEST_SETTING"
RESULT=$(bb-augeas-get-path "$TEST_FILE" "$TEST_SETTING")
bb-assert '[[ "$RESULT" == "$EXPECTED_AUG_PATH" ]]'

# Test file supportability
TEST_FILE="/etc/ssh/sshd_config"
EXPECTED_RESULT=$TRUE
bb-augeas-file-supported? "$TEST_FILE"
RESULT=$?
bb-assert '[[ "$RESULT" == "$EXPECTED_RESULT" ]]'

# Test file supportability
TEST_FILE="/etc/ssh/sshd_config_bad"
EXPECTED_RESULT=$FALSE
bb-augeas-file-supported? "$TEST_FILE"
RESULT=$?
bb-assert '[[ "$RESULT" == "$EXPECTED_RESULT" ]]'

# Test file supportability with path containing space
TEST_FILE="`pwd`/sshd_config.test"
BB_AUGEAS_EXTRA_COMMANDS="transform Ssh incl \"$TEST_FILE\"
load"
EXPECTED_RESULT=$TRUE
bb-augeas-file-supported? "$TEST_FILE"
RESULT=$?
bb-assert '[[ "$RESULT" == "$EXPECTED_RESULT" ]]'


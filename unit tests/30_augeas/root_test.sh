#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-augeas? || exit 255  #  Augeas is not installed, skip test

BB_AUGEAS_ROOT="$( bb-tmp-dir )"
mkdir -p "$BB_AUGEAS_ROOT/etc/ssh"
cp sshd_config.test "$BB_AUGEAS_ROOT/etc/ssh/sshd_config"

TEST_FILE="/etc/ssh/sshd_config"

# Test read
TEST_SETTING="LogLevel"
EXPECT_VALUE="INFO"
VALUE="$(bb-augeas-get "$TEST_FILE" "$TEST_SETTING")"
bb-exit-on-error "Failed"
bb-assert '[[ "$VALUE" == "$EXPECT_VALUE" ]]'

# Test write
TEST_SETTING="Port"
TEST_VALUE="22"
bb-augeas-set "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE"
bb-exit-on-error "Failed"
# Read the setting we just wrote
VALUE="$(bb-augeas-get "$TEST_FILE" "$TEST_SETTING")"
bb-exit-on-error "Failed"
bb-assert '[[ "$VALUE" == "$TEST_VALUE" ]]'

# Test match
TEST_SETTING="LogLevel"
TEST_VALUE="INFO"
EXPECT_RESULT=$TRUE
bb-augeas-match? "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE"
RESULT=$?
bb-assert '[[ $RESULT -eq $EXPECT_RESULT ]]'


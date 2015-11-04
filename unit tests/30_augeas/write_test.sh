#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-augeas? || exit 255  #  Augeas is not installed, skip test

# Mock
EXPECT_EVENT='file-changed'
EXPECT_PARAM=0
bb-event-delay() {
    local EVENT="$1"
    local PARAM="$2"
    [[ -n "$EVENT" ]] || return 0
    bb-assert '[[ "$EVENT" == "$EXPECT_EVENT" ]]'
    bb-assert '[[ "$PARAM" == "$EXPECT_PARAM" ]]'
    (( EVENT_DELAY_CALLED++ ))
}

TEST_FILE="$( bb-tmp-file )"
EVENT_DELAY_CALLED=0

# Make sure Augeas can read our test file
BB_AUGEAS_EXTRA_COMMANDS="transform Ssh incl \"$TEST_FILE\"
load"

# Write a setting
TEST_SETTING="Port"
TEST_VALUE="22"
bb-augeas-set "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE"
bb-exit-on-error "Failed"

# Read the setting we just wrote
VALUE="$(bb-augeas-get "$TEST_FILE" "$TEST_SETTING")"
bb-exit-on-error "Failed"
bb-assert '[[ "$VALUE" == "$TEST_VALUE" ]]'

# Test that an event is delayed when writting a new setting
TEST_SETTING="LogLevel"
TEST_VALUE="INFO"
EVENT_DELAY_CALLED=0
bb-augeas-set "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE" 'file-changed' 0
bb-exit-on-error "Failed"
bb-assert '[[ "$EVENT_DELAY_CALLED" -eq 1 ]]'

# Test that an event is not delayed if no change is done
EVENT_DELAY_CALLED=0
bb-augeas-set "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE" 'event-should-not-be-delayed'
bb-exit-on-error "Failed"
bb-assert '[[ "$EVENT_DELAY_CALLED" -eq 0 ]]'

# Test that an event is delayed when changing a setting
TEST_SETTING="LogLevel"
TEST_VALUE="DEBUG"
EVENT_DELAY_CALLED=0
bb-augeas-set "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE" 'file-changed' 0
bb-exit-on-error "Failed"
bb-assert '[[ "$EVENT_DELAY_CALLED" -eq 1 ]]'

# Test that an argument with space is correctly passed to the event handler
EXPECT_PARAM="arg with space"
TEST_SETTING="LogLevel"
TEST_VALUE="INFO"
EVENT_DELAY_CALLED=0
bb-augeas-set "$TEST_FILE" "$TEST_SETTING" "$TEST_VALUE" 'file-changed' 'arg with space'
bb-exit-on-error "Failed"
bb-assert '[[ "$EVENT_DELAY_CALLED" -eq 1 ]]'


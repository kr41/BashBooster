#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

EXPECT_P1=""
EXPECT_P2=""

bb-event-on event handler
handler() {
    P1="$1"
    P2="$2"
    bb-assert '[[ "$P1" == "$EXPECT_P1"  ]]'
    bb-assert '[[ "$P2" == "$EXPECT_P2"  ]]'
}

EXPECT_P1="p1"
EXPECT_P2="p2"
bb-event-fire event p1 p2

EXPECT_P1="p3"
EXPECT_P2="p4"
bb-event-delay event p3 p4

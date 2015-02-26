#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

RUN_ORDER=""

bb-task-def task1
task1() {
    RUN_ORDER="${RUN_ORDER}1"
}

bb-task-def task2 task2-func
task2-func() {
    bb-task-depends task1
    RUN_ORDER="${RUN_ORDER}2"
}

bb-task-def task3
task3() {
    bb-task-depends task1 task2
    RUN_ORDER="${RUN_ORDER}3"
}

bb-task-run task3

bb-assert '[[ "$RUN_ORDER" == "123" ]]' "$RUN_ORDER != 123"

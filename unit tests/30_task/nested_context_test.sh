#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

RUN_ORDER=""
CONTEXT_LEVEL=""

bb-task-def task1
task1() {
    RUN_ORDER="${RUN_ORDER}1"
    CONTEXT_LEVEL="${CONTEXT_LEVEL}${#BB_TASK_CONTEXT[@]}"
}

bb-task-def task2 task2-func
task2-func() {
    bb-task-run task1
    RUN_ORDER="${RUN_ORDER}2"
    CONTEXT_LEVEL="${CONTEXT_LEVEL}${#BB_TASK_CONTEXT[@]}"
}

bb-task-def task3
task3() {
    bb-task-depends task1 task2
    RUN_ORDER="${RUN_ORDER}3"
    CONTEXT_LEVEL="${CONTEXT_LEVEL}${#BB_TASK_CONTEXT[@]}"
}

bb-task-run task3

bb-assert '[[ "$RUN_ORDER" == "1123" ]]' "$RUN_ORDER != 1123"
bb-assert '[[ "$CONTEXT_LEVEL" == "1211" ]]' "$CONTEXT_LEVEL != 1211"

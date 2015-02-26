#!/usr/bin/env bash

# expect: CODE=1
# expect: STDERR="\[ERROR\] Task 'task2' failed"

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-task-def task1
task1() {
    return 0
}

bb-task-def task2 task2-func
task2-func() {
    bb-task-depends task1
    return 1
}

bb-task-def task3
task3() {
    bb-task-depends task1 task2
    return 0
}

bb-task-run task3

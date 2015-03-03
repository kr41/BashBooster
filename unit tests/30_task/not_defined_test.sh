#!/usr/bin/env bash

# expect: CODE=$BB_ERROR_TASK_UNDEFINED
# expect: STDERR="\[ERROR\] Task 'task1' is not defined"

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

bb-task-def task2
task2() {
    bb-task-depends task1
}

bb-task-run task2

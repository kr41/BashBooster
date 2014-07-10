#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_TEST_OK=0
BB_TEST_FAILED=0

bb-test() {
    local TEST="$1"
    local EXPECT_STDOUT="$DUMMY_OUT"
    local EXPECT_STDERR="$DUMMY_OUT"
    local EXPECT_CODE=0
    local EXPECT_WORKSPACE=0
    if [[ -f "$( dirname "$TEST" )/stdout.txt" ]]
    then
        EXPECT_STDOUT="$( dirname "$TEST" )/stdout.txt"
    fi
    if [[ -f "$( dirname "$TEST" )/stderr.txt" ]]
    then
        EXPECT_STDERR="$( dirname "$TEST" )/stderr.txt"
    fi
    if [[ -f "$( dirname "$TEST" )/code.txt" ]]
    then
        EXPECT_CODE=$(( `cat "$( dirname "$TEST" )/code.txt"` ))
    fi
    if [[ -f "$( dirname "$TEST" )/workspace.lock" ]]
    then
        EXPECT_WORKSPACE=1
    fi

    local STDOUT=`bb-tmp-file`
    local STDERR=`bb-tmp-file`
    chmod a+x "$TEST"
    "$TEST" > "$STDOUT" 2> "$STDERR"

    local CODE=$?
    if [[ $CODE -ne $EXPECT_CODE ]]
    then
        bb-log-error "$TEST Failed"
        bb-log-error "Expected code $EXPECT_CODE is not matching returned one $CODE"
        echo "stderr >>>"
        cat $STDERR
        echo "<<< stderr"
        echo "stdout >>>"
        cat $STDOUT
        echo "<<< stdout"
        BB_TEST_FAILED=$(( $BB_TEST_FAILED + 1 ))
        return
    fi
    if [[ `diff -q "$EXPECT_STDOUT" "$STDOUT"` ]]
    then
        bb-log-error "$TEST Failed"
        bb-log-error "Expected output in stdout differs from given one"
        echo "expected >>>"
        cat $EXPECT_STDOUT
        echo "<<< expected"
        echo "given >>>"
        cat $STDOUT
        echo "<<< given"
        BB_TEST_FAILED=$(( $BB_TEST_FAILED + 1 ))
        return
    fi
    if [[ `diff -q "$EXPECT_STDERR" "$STDERR"` ]]
    then
        bb-log-error "$TEST Failed"
        bb-log-error "Expected output in stderr differs from given one"
        echo "expected >>>"
        cat $EXPECT_STDERR
        echo "<<< expected"
        echo "given >>>"
        cat $STDERR
        echo "<<< given"
        BB_TEST_FAILED=$(( $BB_TEST_FAILED + 1 ))
        return
    fi
    if [[ -d "$( dirname "$TEST" )/.bb-workspace" && $EXPECT_WORKSPACE -eq 0 ]]
    then
        bb-log-error "$TEST Failed"
        bb-log-error "Workspace directory still exists"
        BB_TEST_FAILED=$(( $BB_TEST_FAILED + 1 ))
        return
    fi
    bb-log-info "$TEST OK"
    BB_TEST_OK=$(( $BB_TEST_OK + 1 ))
}

bb-test-stat() {
    if [[ $BB_TEST_OK -ne 0 ]]
    then
        bb-log-info "Total passed tests: $BB_TEST_OK"
    fi
    if [[ $BB_TEST_FAILED -ne 0 ]]
    then
        bb-log-info "Total failed tests: $BB_TEST_FAILED"
        return 1
    fi
}

./build.sh

BB_WORKSPACE="test.bb-workspace"
BB_LOG_PREFIX="bashbooster-test"
BB_LOG_USE_COLOR=1
source bashbooster.sh

DUMMY_OUT=`bb-tmp-file`

TEST="$1"
if [[ -z "$TEST" ]]
then
    IFS=`echo -e "\n\b"`
    for TEST in `find "./unit tests" -name "test.sh" | sort`
    do
        bb-test "$TEST"
    done
    unset IFS
else
    bb-test "$TEST"
fi

bb-test-stat

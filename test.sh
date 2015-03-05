#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BASHBOOSTER="$( pwd )/dist/bashbooster.sh"

BB_TEST_OK=0
BB_TEST_SKIPPED=0
BB_TEST_FAILED=0

run-test() {
    local TEST="$1"
    local TEST_DIR="$( dirname "$TEST" )"

    eval "$(
        cat "$TEST" |
        grep '# expect:' |
        awk '{ print "local EXPECT_" substr($0, length("# expect :") + 1) }'
    )"
    if [[ -z "$EXPECT_CODE" ]]
    then
        local EXPECT_CODE=0
    fi

    local STDOUT="$( bb-tmp-file )"
    local STDERR="$( bb-tmp-file )"
    chmod a+x "$TEST"
    BB_LOG_LEVEL='debug' BASHBOOSTER="$BASHBOOSTER" "$TEST" > "$STDOUT" 2> "$STDERR"

    local CODE=$?
    local FAIL_MESSAGE=""

    if (( $CODE == 255 ))
    then
        bb-log-info "$TEST SKIPPED"
        BB_TEST_SKIPPED=$(( $BB_TEST_SKIPPED + 1 ))
        return
    fi

    if (( $CODE != $EXPECT_CODE ))
    then
        FAIL_MESSAGE="Expected code $EXPECT_CODE is not matching returned one $CODE"
    fi
    if [[ -n "$EXPECT_STDOUT" ]] && [[ -z "$( cat "$STDOUT" | grep "$EXPECT_STDOUT" )" ]]
    then
        FAIL_MESSAGE="Given stdout does not contain expected '$EXPECT_STDOUT'"
    fi
    if [[ -n "$EXPECT_STDOUT_FILE" ]] && [[ -n "$( diff -q "$EXPECT_STDOUT_FILE" "$STDOUT" )" ]]
    then
        FAIL_MESSAGE="Given stdout and expected one '$EXPECT_STDOUT_FILE' are not matching"
    fi
    if [[ -n "$EXPECT_STDERR" ]] && [[ -z "$( cat "$STDERR" | grep "$EXPECT_STDERR" )" ]]
    then
        FAIL_MESSAGE="Given stderr does not contain expected '$EXPECT_STDERR'"
    fi
    if [[ -n "$EXPECT_STDERR_FILE" ]] && [[ -n "$( diff -q "$EXPECT_STDERR_FILE" "$STDERR" )" ]]
    then
        FAIL_MESSAGE="Given stderr and expected one '$EXPECT_STDERR_FILE' are not matching"
    fi
    if [[ -d "$TEST_DIR/.bb-workspace" ]]
    then
        FAIL_MESSAGE="Workspace directory still exists"
        rm -rf "$TEST_DIR/.bb-workspace"
    fi

    if [[ -n "$FAIL_MESSAGE" ]]
    then
        bb-log-error "$TEST Failed"
        bb-log-error "$FAIL_MESSAGE"
        if [[ -n "$( cat "$STDERR" )" ]]
        then
            echo "stderr >>>"
            cat "$STDERR"
            echo "<<< stderr"
        fi
        if [[ -n "$( cat "$STDOUT" )" ]]
        then
            echo "stdout >>>"
            cat "$STDOUT"
            echo "<<< stdout"
        fi
        BB_TEST_FAILED=$(( $BB_TEST_FAILED + 1 ))
        return
    fi
    bb-log-info "$TEST OK"
    BB_TEST_OK=$(( $BB_TEST_OK + 1 ))
}

print-test-stat() {
    if (( $BB_TEST_OK > 0 ))
    then
        bb-log-info "Total passed tests: $BB_TEST_OK"
    fi
    if (( $BB_TEST_SKIPPED > 0 ))
    then
        bb-log-info "Total skipped tests: $BB_TEST_SKIPPED"
    fi
    if (( $BB_TEST_FAILED > 0 ))
    then
        bb-log-info "Total failed tests: $BB_TEST_FAILED"
        return 1
    fi
}

./build.sh

BB_WORKSPACE="test.bb-workspace"
BB_LOG_FORMAT='${PREFIX} ${TIME} [${LEVEL}] ${MESSAGE}'
BB_LOG_USE_COLOR=true
source "$BASHBOOSTER"


TEST="$1"
if [[ -f "$TEST" ]]
then
    run-test "$TEST"
else
    if [[ -d "$TEST" ]]
    then
        TEST_DIR="$TEST"
    else
        TEST_DIR='./unit tests'
    fi
    while read -r TEST
    do
        run-test "$TEST"
    done < <( find "$TEST_DIR" -name "*test.sh" | sort )
fi

print-test-stat

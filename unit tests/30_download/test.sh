#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

# expect: STDERR='mock: wget'

# Mock
wget() {
    bb-log-info "mock: wget"
}

FILE1="$( bb-download 'http://example.com/file.txt' )"
FILE2="$( bb-download 'http://example.com/file.txt' 'file2.txt' )"

FILE1="$( echo $FILE1 | awk "{ print substr(\$0, length(\"$BB_WORKSPACE\") + 2) }" )"
FILE2="$( echo $FILE2 | awk "{ print substr(\$0, length(\"$BB_WORKSPACE\") + 2) }" )"

bb-assert '[[ "$FILE1" == "download/file.txt" ]]'
bb-assert '[[ "$FILE2" == "download/file2.txt" ]]'

bb-download-clean

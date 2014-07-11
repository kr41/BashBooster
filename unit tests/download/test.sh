#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../bashbooster.sh

# Mock
wget() {
    bb-log-info "mock: wget"
}

FILE=`bb-download 'http://example.com/file.txt'`
FILE2=`bb-download 'http://example.com/file.txt' 'file2.txt'`

echo $FILE | awk "{ print substr(\$0, length(\"$BB_WORKSPACE\") + 2) }"
echo $FILE2 | awk "{ print substr(\$0, length(\"$BB_WORKSPACE\") + 2) }"

bb-download-clean

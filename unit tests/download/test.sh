#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_PREFIX='test-download'
source ../../bashbooster.sh

# Mock
wget() {
    bb-log-info "mock: wget $@"
}

bb-download 'http://example.com/file.txt'
bb-download 'http://example.com/file.txt' 'file2.txt'

bb-download-clean

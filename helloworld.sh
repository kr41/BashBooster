#!/bin/bash

# Remove undesirable side effects of CDPATH variable
unset CDPATH
# Change current working directory to the directory contains this script
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Initialize Bash Booster
source bashbooster.sh

# Log message with log level "INFO"
bb-log-info "Hello World"

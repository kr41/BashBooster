#!/bin/bash

BB_LOG_PREFIX='test-workspace'
source ../bashbooster.sh

[[ -d "$BB_WORKSPACE" ]] || die 1 "Workspace doesn't exist"

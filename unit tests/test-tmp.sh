#!/bin/bash

BB_LOG_PREFIX='test-tmp'
source ../bashbooster.sh

FILE=`bb-tmp-file`
[[ -f $FILE ]] || bb-die 1 "File doesn't exist"

DIR=`bb-tmp-dir`
[[ -d $DIR ]] || bb-die 1 "Directory doesn't exist"

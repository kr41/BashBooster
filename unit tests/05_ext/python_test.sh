#!/usr/bin/env bash


unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"


bb-ext-python 'py-func' <<EOF
import sys
print("%s %s!" % tuple(sys.argv[1:]))
EOF

bb-assert '[[ "$( py-func "Hello" "from Python"  )" == "Hello from Python!" ]]'

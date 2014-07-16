#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

OUTPUT="bashbooster.sh"

> $OUTPUT
for FILE in $( find ./source -name "*.sh" | sort )
do
    echo -e "##\n# $FILE\n#\n" >> $OUTPUT
    cat $FILE >> $OUTPUT
    echo >> $OUTPUT
done

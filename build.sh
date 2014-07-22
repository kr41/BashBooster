#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

OUTPUT="bashbooster.sh"
> $OUTPUT

TITLE="Bash Booster $( cat VERSION.txt ) <http://www.bashbooster.net>"
cat >> "$OUTPUT" <<EOF
# $TITLE
# $( eval "printf '=%.0s' {1..${#TITLE}}" )
#
$( cat LICENSE.txt | awk '{ print "# "$0 }' )
#

EOF

while read -r FILE
do
    echo -e "##\n# $FILE\n#\n" >> "$OUTPUT"
    cat "$FILE" >> "$OUTPUT"
    echo >> "$OUTPUT"
done < <( find ./source -name "*.sh" | sort )

# normalizing, reading and evaluating key=value lines from the properties file
# regexp searches for lines with key=value, key:value, key: value etc.. pattern,
# see http://docs.oracle.com/javase/7/docs/api/java/util/Properties.html#load(java.io.Reader)
bb-ext-python 'bb-read-properties-helper' <<EOF
import re
import sys

filename = sys.argv[1]
prefix = sys.argv[2]
with open(filename, 'r') as properties:
    for line in properties:
        line = line.strip()
        match = re.match(r'^(?P<key>[^#!]*?)[\s:=]+(?P<value>.+)', line)
        if match:
            match = match.groupdict()
            match['key'] = re.sub(r'[\W]', '_', match['key'])
            print('{prefix}{key}="{value}"'.format(prefix=prefix, **match))
EOF

bb-read-properties() {
    local FILENAME="$1"
    local PREFIX="$2"

    if [[ ! -r "$FILENAME" ]]
    then
        bb-log-error "'$FILENAME' is not readable"
        return 1
    fi

    eval "$( bb-read-properties-helper "$FILENAME" "$PREFIX" )"
}

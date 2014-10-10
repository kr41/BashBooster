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


bb-ext-python 'bb-read-ini-helper' <<EOF
import re
import sys
try:
    from ConfigParser import SafeConfigParser as ConfigParser
except ImportError:
    # Python 3.x
    from configparser import ConfigParser

filename = sys.argv[1]
section = sys.argv[2]
prefix = sys.argv[3]
reader = ConfigParser()
reader.read(filename)

if section == '*':
    sections = reader.sections()
else:
    sections = [section]
for section in sections:
    for key, value in reader.items(section):
        section = re.sub(r'[\W]', '_', section)
        key = re.sub(r'[\W]', '_', key)
        print(
            '{prefix}{section}_{key}="{value}"'.format(
                prefix=prefix,
                section=section,
                key=key,
                value=value
            )
        )
EOF

bb-read-ini() {
    local FILENAME="$1"
    local SECTION="$2"
    local PREFIX="$3"

    if [[ ! -r "$FILENAME" ]]
    then
        bb-log-error "'$FILENAME' is not readable"
        return 1
    fi

    eval "$( bb-read-ini-helper "$FILENAME" "$SECTION" "$PREFIX" )"
}

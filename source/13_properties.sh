bb-properties-read() {
    local FILENAME="$1"
    local PREFIX="$2"

    if [[ ! -r "$FILENAME" ]]
    then
        bb-log-warning "'$FILENAME' is not readable"
        return
    fi

    # normalizing, reading and evaluating key=value lines from the properties file
    # regexp searches for lines with key=value, key:value, key: value etc.. pattern, see http://docs.oracle.com/javase/7/docs/api/java/util/Properties.html#load(java.io.Reader)
    # gawk normalizes such lines to key="value" form
    # eval executes the key="value" definitions to define Bash variables
    while read line
    do
#        echo "$line"
        eval "$line"
    done < <(gawk 'match($0, \
                        /^([^[:blank:]#!][^[:blank:]:=]*)[[:blank:]:=]+(.+)[[:blank:]]*/ \
                        , m) \
                        { \
                            gsub(/[^a-zA-Z0-9_]/, "_", m[1]);
                            print "'$PREFIX'" m[1] "=\"" m[2] "\"" \
                        }' $FILENAME)
}

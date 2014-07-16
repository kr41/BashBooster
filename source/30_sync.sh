bb-sync-file() {
    local DST_FILE="$1"
    local SRC_FILE="$2"
    local EVENT="$3"
    if [[ ! -f "$DST_FILE" ]]
    then
        touch "$DST_FILE"
        bb-event-delay "$EVENT"
    fi
    if [[ -n "$( diff -q "$SRC_FILE" "$DST_FILE" )" ]]
    then
        cp -f "$SRC_FILE" "$DST_FILE"
        bb-event-delay "$EVENT"
    fi
}

bb-sync-dir() {
    local DST_DIR="$1"
    local SRC_DIR="$2"
    local EVENT="$3"
    if [[ ! -d "$DST_DIR" ]]
    then
        mkdir -p "$DST_DIR"
        bb-event-delay "$EVENT"
    fi

    local ORIGINAL_DIR="$( pwd )"

    cd "$SRC_DIR"
    for NAME in $( ls )
    do
        if [[ -f "$SRC_DIR/$NAME" ]]
        then
            bb-sync-file "$DST_DIR/$NAME" "$SRC_DIR/$NAME" "$EVENT"
        elif [[ -d "$SRC_DIR/$NAME" ]]
        then
            bb-sync-dir "$DST_DIR/$NAME" "$SRC_DIR/$NAME" "$EVENT"
        fi
    done
    cd "$DST_DIR"
    IFS="$( echo -e "\n\b" )"
    for FILE in $( find )
    do
        if [[ ! -e "$SRC_DIR/$FILE" ]]
        then
            rm -rf "$DST_DIR/$FILE"
            bb-event-delay "$EVENT"
        fi
    done
    unset IFS

    cd "$ORIGINAL_DIR"
}

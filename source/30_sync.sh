bb-sync-file() {
    local DST_FILE="$1"
    local SRC_FILE="$2"
    shift 2
    local EVENT="$@"
    if [[ ! -f "$DST_FILE" ]]
    then
        touch "$DST_FILE"
        bb-event-delay $EVENT
    fi
    if [[ -n "$( diff -q "$SRC_FILE" "$DST_FILE" )" ]]
    then
        cp -f "$SRC_FILE" "$DST_FILE"
        bb-event-delay $EVENT
    fi
}

bb-sync-dir() {
    local DST_DIR="$( readlink -nm "$1" )"
    local SRC_DIR="$( readlink -ne "$2" )"
    shift 2
    local EVENT="$@"
    if [[ ! -d "$DST_DIR" ]]
    then
        mkdir -p "$DST_DIR"
        bb-event-delay $EVENT
    fi

    local ORIGINAL_DIR="$( pwd )"
    local NAME

    cd "$SRC_DIR"
    while read -r NAME
    do
        if [[ -f "$SRC_DIR/$NAME" ]]
        then
            bb-sync-file "$DST_DIR/$NAME" "$SRC_DIR/$NAME" "$EVENT"
        elif [[ -d "$SRC_DIR/$NAME" ]]
        then
            bb-sync-dir "$DST_DIR/$NAME" "$SRC_DIR/$NAME" "$EVENT"
        fi
    done < <( ls )
    cd "$DST_DIR"
    while read -r NAME
    do
        if [[ ! -e "$SRC_DIR/$NAME" ]]
        then
            rm -rf "$DST_DIR/$NAME"
            bb-event-delay $EVENT
        fi
    done < <( find . )

    cd "$ORIGINAL_DIR"
}

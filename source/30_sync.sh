bb-sync-file() {
    local DST_FILE="$1"
    local SRC_FILE="$2"
    shift 2

    local DST_FILE_CHANGED=0

    if [[ ! -f "$DST_FILE" ]]
    then
        touch "$DST_FILE"
        bb-event-delay "$@"
        DST_FILE_CHANGED=1
    fi
    if [[ -n "$( diff -q "$SRC_FILE" "$DST_FILE" )" ]]
    then
        cp -f "$SRC_FILE" "$DST_FILE"
        bb-event-delay "$@"
        DST_FILE_CHANGED=1
    fi

    if [ "$DST_FILE_CHANGED" -eq 1 ]
    then
        bb-event-fire "bb-sync-file-changed" "$DST_FILE"
    fi
}

bb-sync-dir-helper() {
    local ONE_WAY="$1"
    shift
    local DST_DIR="$( readlink -nm "$1" )"
    local SRC_DIR="$( readlink -ne "$2" )"
    shift 2

    if [[ ! -d "$DST_DIR" ]]
    then
        mkdir -p "$DST_DIR"
        bb-event-delay "$@"
        bb-event-fire "bb-sync-dir-created" "$DST_DIR"
    fi

    local ORIGINAL_DIR="$( pwd )"
    local NAME

    cd "$SRC_DIR"
    while read -r NAME
    do
        if [[ -f "$SRC_DIR/$NAME" ]]
        then
            bb-sync-file "$DST_DIR/$NAME" "$SRC_DIR/$NAME" "$@"
        elif [[ -d "$SRC_DIR/$NAME" ]]
        then
            bb-sync-dir-helper "$ONE_WAY" "$DST_DIR/$NAME" "$SRC_DIR/$NAME" "$@"
        fi
    done < <( ls )
    cd "$DST_DIR"
    while [ "$ONE_WAY" -eq 0 ] && read -r NAME
    do
        if [[ ! -e "$SRC_DIR/$NAME" ]]
        then
            local EVENT="bb-sync-file-removed"
            if [[ -d "$DST_DIR/$NAME" ]]
            then
                EVENT="bb-sync-dir-removed"
            fi
            rm -rf "$DST_DIR/$NAME"
            bb-event-delay "$@"
            bb-event-fire "$EVENT" "$DST_DIR/$NAME"
        fi
    done < <( find . )

    cd "$ORIGINAL_DIR"
}

bb-sync-dir() {
    bb-sync-dir-helper 0 "$@"
}

bb-sync-dir-one-way() {
    bb-sync-dir-helper 1 "$@"
}


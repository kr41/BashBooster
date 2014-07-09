bb-sync-file() {
    local DST_FILE="$1"
    local SRC_FILE="$2"
    local EVENT="$3"
    if [[ ! -f "$DST_FILE" ]]
    then
        touch "$DST_FILE"
        bb-event-delay "$EVENT"
    fi
    if [[ -n `diff -q "$SRC_FILE" "$DST_FILE"` ]]
    then
        cat "$SRC_FILE" > "$DST_FILE"
        bb-event-delay "$EVENT"
    fi
}

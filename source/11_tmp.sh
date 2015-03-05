BB_TMP=''

bb-tmp-init() {
    BB_TMP="$BB_WORKSPACE/tmp_$( bb-unique )"
    mkdir "$BB_TMP"
}

bb-tmp-file() {
    local FILENAME="$BB_TMP/$( bb-unique )"
    touch "$FILENAME"
    echo "$FILENAME"
}

bb-tmp-dir() {
    local DIRNAME="$BB_TMP/$( bb-unique )"
    mkdir -p "$DIRNAME"
    echo "$DIRNAME"
}

bb-tmp-cleanup() {
    rm -rf "$BB_TMP"
}

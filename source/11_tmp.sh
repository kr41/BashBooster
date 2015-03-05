BB_TMP=''

bb-tmp-init() {
    BB_TMP="$BB_WORKSPACE/tmp_$( bb-tmp-name )"
    mkdir "$BB_TMP"
}

bb-tmp-file() {
    local FILENAME="$BB_TMP/$( bb-tmp-name )"
    touch "$FILENAME"
    echo "$FILENAME"
}

bb-tmp-dir() {
    local DIRNAME="$BB_TMP/$( bb-tmp-name )"
    mkdir -p "$DIRNAME"
    echo "$DIRNAME"
}

bb-tmp-name() {
    echo "$( date +%s )$RANDOM"
}

bb-tmp-cleanup() {
    rm -rf "$BB_TMP"
}


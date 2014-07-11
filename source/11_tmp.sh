bb-tmp-init() {
    if [[ -d "$BB_WORKSPACE/tmp" ]]
    then
        rm -rf "$BB_WORKSPACE/tmp/"
    fi
    mkdir "$BB_WORKSPACE/tmp"
}

bb-tmp-file() {
    FILENAME="$BB_WORKSPACE/tmp/`date +%s%N`"
    touch "$FILENAME"
    echo "$FILENAME"
}

bb-tmp-dir() {
    DIRNAME="$BB_WORKSPACE/tmp/`date +%s%N`"
    mkdir -p "$DIRNAME"
    echo "$DIRNAME"
}

bb-tmp-cleanup() {
    rm -rf "$BB_WORKSPACE/tmp"
}

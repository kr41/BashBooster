BB_DOWNLOAD_DIR="$BB_WORKSPACE/download"

bb-download() {
    if [[ ! -d "$BB_DOWNLOAD_DIR" ]]
    then
        mkdir "$BB_DOWNLOAD_DIR"
    fi

    local URL="$1"
    local TARGET="$2"
    if [[ -z "$TARGET" ]]
    then
        TARGET="$( basename "$URL" )"
    fi
    TARGET="$BB_DOWNLOAD_DIR/$TARGET"

    wget -O "$TARGET" -nc "$URL"
    echo "$TARGET"
}

bb-download-clean() {
    rm -rf "$BB_DOWNLOAD_DIR"
}

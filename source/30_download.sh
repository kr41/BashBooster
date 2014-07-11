BB_DOWNLOAD_DIR="$BB_WORKSPACE/download"

bb-download() {
    if [[ ! -d "$BB_DOWNLOAD_DIR" ]]
    then
        bb-log-debug "Creating download directory at '$BB_DOWNLOAD_DIR'"
        mkdir "$BB_DOWNLOAD_DIR"
    fi

    local URL="$1"
    local TARGET="${2-`basename "$URL"`}"
    TARGET="$BB_DOWNLOAD_DIR/$TARGET"

    bb-log-info "Downloading $URL"
    wget -O "$TARGET" -nc "$URL"
    echo "$TARGET"
}

bb-download-clean() {
    rm -rf "$BB_DOWNLOAD_DIR"
}

bb-download-init() {
    BB_DOWNLOAD_DIR="$BB_WORKSPACE/download"
}

bb-download() {
    if [[ ! -d "$BB_DOWNLOAD_DIR" ]]
    then
        bb-log-debug "Creating download directory at '$BB_DOWNLOAD_DIR'"
        mkdir "$BB_DOWNLOAD_DIR"
    fi

    local URL="$1"
    local TARGET="${2-$( basename "$URL" )}"
    TARGET="$BB_DOWNLOAD_DIR/$TARGET"

    bb-log-info "Downloading $URL"
    wget -nv -O "$TARGET" -nc "$URL"
    if bb-error?
    then
        bb-log-error "Unable to get $URL"
        rm "$TARGET"
        return $BB_ERROR
    fi
    echo "$TARGET"
}

bb-download-clean() {
    rm -rf "$BB_DOWNLOAD_DIR"
}

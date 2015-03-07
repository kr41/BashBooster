bb-var BB_BREW_UPDATED false

bb-brew?() {
    bb-exe? brew
}

bb-brew-tap?() {
    local REPO=$1
    brew tap | grep -q "$REPO"
}

bb-brew-package?() {
    local PACKAGE=$1
    [ -n "$(brew ls --versions "$PACKAGE")" ]
}

bb-brew-update() {
    $BB_BREW_UPDATED && return 0
    bb-log-info 'Updating Homebrew'
    brew update
    BB_BREW_UPDATED=true
}

bb-brew-install() {
    for PACKAGE in "$@"
    do
        if ! bb-brew-package? "$PACKAGE"
        then
            bb-brew-update
            bb-log-info "Installing package '$PACKAGE'"
            brew install "$PACKAGE"
            local STATUS=$?
            if (( $STATUS == 0 ))
            then
                bb-event-fire "bb-package-installed" "$PACKAGE"
            else
                bb-exit $STATUS "Failed to install package '$PACKAGE'"
            fi
        fi
    done
}

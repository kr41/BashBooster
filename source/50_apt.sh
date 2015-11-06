bb-var BB_APT_UPDATED false

bb-apt?() {
    bb-exe? apt-get
}

bb-apt-repo?() {
    local REPO=$1
    cat /etc/apt/sources.list /etc/apt/sources.list.d/* 2> /dev/null | grep -v '^#' | grep -qw "$REPO"
}

bb-apt-package?() {
    local PACKAGE=$1
    dpkg -s "$PACKAGE" 2> /dev/null | grep -q '^Status:.\+installed'
}

bb-apt-update() {
    $BB_APT_UPDATED && return 0
    bb-log-info 'Updating apt cache'
    apt-get update
    BB_APT_UPDATED=true
}

bb-apt-install() {
    for PACKAGE in "$@"
    do
        if ! bb-apt-package? "$PACKAGE"
        then
            bb-apt-update
            bb-log-info "Installing package '$PACKAGE'"
            apt-get install -y "$PACKAGE"
            bb-exit-on-error "Failed to install package '$PACKAGE'"
            bb-event-fire "bb-package-installed" "$PACKAGE"
        fi
    done
}

bb-apt-package-upgrade?() {
    bb-apt-update

    local PACKAGE=$1
    local OUTPUT="$(apt-cache policy "$PACKAGE" | grep -A 1 'Installed: ' | sed -r 's/(Installed: |Candidate: )//'| sed '/ (none)/I,+1 d' | uniq -u)"

    # Note: No upgrade available is reported for a non-installed package
    [ -n "$OUTPUT" ]
}

bb-apt-upgrade() {
    for PACKAGE in "$@"
    do
        if bb-apt-package-upgrade? "$PACKAGE"
        then
            bb-log-info "Upgrading package '$PACKAGE'"
            bb-event-fire "bb-package-pre-upgrade" "$PACKAGE"
            apt-get upgrade -y "$PACKAGE"
            bb-exit-on-error "Failed to upgrade package '$PACKAGE'"
            bb-event-fire "bb-package-post-upgrade" "$PACKAGE"
        fi
    done
}


bb-var BB_APT_UPDATED false

bb-apt() {
    type -t apt-get > /dev/null
}

bb-apt-repo() {
    local REPO=$1
    cat /etc/apt/sources.list /etc/apt/sources.list.d/* 2> /dev/null | grep -v '^#' | grep -qw "$REPO"
}

bb-apt-package() {
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
        if ! bb-apt-package "$PACKAGE"
        then
            bb-apt-update
            bb-log-info "Installing package '$PACKAGE'"
            apt-get install -y "$PACKAGE"
        fi
    done
}

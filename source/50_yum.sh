bb-var BB_YUM_UPDATED false

bb-yum?() {
    type -t yum > /dev/null
}

bb-yum-repo?() {
    local REPO=$1
    yum -C repolist | grep -qw "^$REPO"
}

bb-yum-package?() {
    local PACKAGE=$1
    yum -C list installed "$PACKAGE" &> /dev/null
}

bb-yum-update() {
    $BB_YUM_UPDATED && return 0
    bb-log-info 'Updating yum cache'
    yum clean all
    yum makecache
    BB_YUM_UPDATED=true
}

bb-yum-install() {
    for PACKAGE in "$@"
    do
        if ! bb-yum-package? "$PACKAGE"
        then
            bb-yum-update
            bb-log-info "Installing package '$PACKAGE'"
            yum install -y "$PACKAGE"
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

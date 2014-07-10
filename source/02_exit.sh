bb-exit() {
    local CODE=$1
    shift
    if (( $CODE == 0 ))
    then
        bb-log-info "$@"
    else
        bb-log-error "$@"
    fi
    exit $CODE
}

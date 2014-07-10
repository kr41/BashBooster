bb-var BB_WORKSPACE ".bb-workspace"

BB_WORKSPACE_ERROR=10

bb-workspace-init() {
    bb-log-debug "Initializing workspace at '$BB_WORKSPACE'"
    if [[ ! -d "$BB_WORKSPACE" ]]
    then
        mkdir -p "$BB_WORKSPACE" || \
        bb-exit $BB_WORKSPACE_ERROR "Failed to initialize workspace at '$BB_WORKSPACE'"
    fi

    # Ensure BB_WORKSPACE stores absolute path
    cd "$BB_WORKSPACE"
    BB_WORKSPACE=`pwd`
    cd - > /dev/null
}

bb-workspace-cleanup() {
    bb-log-debug "Cleaning up workspace at '$BB_WORKSPACE'"
    if [[ -z `ls "$BB_WORKSPACE"` ]]
    then
        bb-log-debug "Workspace is empty. Removing"
        rm -rf "$BB_WORKSPACE"
    else
        bb-log-debug "Workspace is not empty"
    fi
}

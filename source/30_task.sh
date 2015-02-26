BB_TASK_CONTEXT_ERROR=30

declare -A BB_TASK_FUNCS
declare -a BB_TASK_CONTEXT

bb-task-def() {
    local NAME="$1"
    local FUNC="${2-${NAME}}"
    BB_TASK_FUNCS[$NAME]="$FUNC"
}

bb-task-run() {
    BB_TASK_CONTEXT[${#BB_TASK_CONTEXT[@]}]="$( bb-tmp-file )"
    bb-task-depends "$@"
    unset BB_TASK_CONTEXT[-1]
}

bb-task-depends() {
    local CONTEXT="${BB_TASK_CONTEXT[-1]}"
    local CODE
    local NAME

    if [[ ! -f "$CONTEXT" ]]
    then
        bb-exit $BB_TASK_CONTEXT_ERROR "Cannot run tasks. Bad context"
    fi
    for NAME in "$@"
    do
        if [[ -z $( cat "$CONTEXT" | grep "^$NAME$" ) ]]
        then
            bb-log-info "Running task '$NAME'..."
            ${BB_TASK_FUNCS[$NAME]}
            CODE=$?
            if (( $CODE != 0 ))
            then
                bb-exit $CODE "Task '$NAME' failed"
            fi
            bb-log-info "Task '$NAME' OK"
        fi
        echo "$NAME" >> "$BB_TASK_CONTEXT"
    done
}

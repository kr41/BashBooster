declare -A BB_EVENT_DEPTH
BB_EVENT_DELAY_DEPTH=0
BB_EVENT_MAX_DEPTH=1000
BB_EVENT_ERROR_MAX_DEPTH_REACHED=20

bb-event-init() {
    BB_EVENT_DIR=`bb-tmp-dir`
}

bb-event-on() {
    local EVENT=$1
    local HANDLER=$2
    local HANDLERS="$BB_EVENT_DIR/$EVENT.handlers"
    touch "$HANDLERS"
    if [[ -z `cat "$HANDLERS" | grep '$HANDLER'` ]]
    then
        bb-log-debug "Subscribed handler '$HANDLER' on event '$EVENT'"
        echo "$HANDLER" >> "$HANDLERS"
    fi
}

bb-event-fire() {
    local EVENT=$1
    [[ -n "$EVENT" ]] || return 0
    BB_EVENT_DEPTH["$EVENT"]=$(( ${BB_EVENT_DEPTH["$EVENT"]} + 1 ))
    if (( ${BB_EVENT_DEPTH["$EVENT"]} >= $BB_EVENT_MAX_DEPTH ))
    then
        bb-exit $BB_EVENT_ERROR_MAX_DEPTH_REACHED "Max recursion depth has been reached on processing event '$EVENT'"
    fi
    if [[ -f "$BB_EVENT_DIR/$EVENT.handlers" ]]
    then
        bb-log-debug "Run handlers for event '$EVENT'"
        source "$BB_EVENT_DIR/$EVENT.handlers"
    fi
    BB_EVENT_DEPTH["$EVENT"]=$(( ${BB_EVENT_DEPTH["$EVENT"]} - 1 ))
}

bb-event-delay() {
    local EVENT=$1
    local EVENTS="$BB_EVENT_DIR/events"
    [[ -n "$EVENT" ]] || return 0
    touch "$EVENTS"
    if [[ -z `cat "$EVENTS" | grep "^$EVENT\$"` ]]
    then
        bb-log-debug "Delayed event '$EVENT'"
        echo "$EVENT" >> "$EVENTS"
    fi
}

bb-event-cleanup() {
    BB_EVENT_DEPTH["__delay__"]=$(( ${BB_EVENT_DEPTH["__delay__"]} + 1 ))
    if (( ${BB_EVENT_DEPTH["__delay__"]} >= $BB_EVENT_MAX_DEPTH ))
    then
        bb-exit $BB_EVENT_ERROR_MAX_DEPTH_REACHED "Max recursion depth has been reached on processing event '__delay__'"
        return $?
    fi
    local EVENTS="$BB_EVENT_DIR/events"
    if [[ -f "$EVENTS" ]]
    then
        local EVENT_LIST=`cat "$EVENTS"`
        rm "$EVENTS"
        for EVENT in $EVENT_LIST
        do
            bb-event-fire $EVENT
        done
        # If any event hadler calls ``bb-event-delay``, the ``$EVENTS`` file
        # will be created again and we should repeat this processing
        if [[ -f "$EVENTS" ]]
        then
            bb-event-cleanup
        fi
    fi
    BB_EVENT_DEPTH["__delay__"]=$(( ${BB_EVENT_DEPTH["__delay__"]} - 1 ))
}

BB_LOG_DEBUG=1
BB_LOG_INFO=2
BB_LOG_WARNING=3
BB_LOG_ERROR=4

bb-var BB_LOG_LEVEL $BB_LOG_INFO
bb-var BB_LOG_PREFIX 'bashbooster'
bb-var BB_LOG_USE_COLOR false
bb-var BB_LOG_USE_TIME false

declare -A BB_LOG_COLORS

bb-log-init() {
    if $BB_LOG_USE_COLOR
    then
        BB_LOG_COLORS[$BB_LOG_DEBUG]='\e[1;30m'      # Dark Gray
        BB_LOG_COLORS[$BB_LOG_INFO]='\e[0;32m'       # Green
        BB_LOG_COLORS[$BB_LOG_WARNING]='\e[0;33m'    # Brown/Orange
        BB_LOG_COLORS[$BB_LOG_ERROR]='\e[0;31m'      # Red
        BB_LOG_COLORS['NC']='\e[0m'
    fi
    if $BB_LOG_USE_TIME
    then
        bb-var BB_LOG_TIME 'date --rfc-3339=seconds'
    else
        bb-var BB_LOG_TIME 'echo'
    fi
}

bb-log-msg() {
    local LEVEL=$1
    shift
    if (( $LEVEL >= $BB_LOG_LEVEL ))
    then
        local COLOR=${BB_LOG_COLORS[$LEVEL]}
        local NOCOLOR=${BB_LOG_COLORS['NC']}
        local TIME=`$BB_LOG_TIME`
        [[ -n "$TIME" ]] && TIME=" $TIME"
        echo -e "${COLOR}${BB_LOG_PREFIX}${TIME} $@${NOCOLOR}" >&2
    fi
}

bb-log-debug() {
    bb-log-msg $BB_LOG_DEBUG "[DEBUG] $@"
}

bb-log-info() {
    bb-log-msg $BB_LOG_INFO "[INFO] $@"
}

bb-log-warning() {
    bb-log-msg $BB_LOG_WARNING "[WARNING] $@"
}

bb-log-error() {
    bb-log-msg $BB_LOG_ERROR "[ERROR] $@"
}

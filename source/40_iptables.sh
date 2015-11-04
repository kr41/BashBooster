# True if `iptables` is executable
bb-iptables?() {
    bb-exe? iptables
}

# True if given chain exists.
bb-iptables-chain?() {
    local USAGE='bb-iptables-chain? [-t,--table TABLE=filter] CHAIN'
    local TABLE="filter"
    local ARG
    local -a ARGS
    while [[ $# > 0 ]]
    do
        KEY="$1"
        shift
        case $KEY in
            --table=*)
                TABLE="${KEY#*=}"
                ;;
            -t|--table)
                TABLE="$1"
                shift
                ;;
            *)
                ARGS+=("$KEY")
                ;;
        esac
    done
    local CHAIN="${ARGS[0]}"
    bb-assert 'test -n "$CHAIN"' "usage: $USAGE"
    iptables -t $TABLE -nL "$CHAIN" > /dev/null 2> /dev/null
}

# Create chain if does not already exist.
bb-iptables-chain() {
    local USAGE='bb-iptables-chain [-t,--table TABLE=filter] CHAIN'
    local TABLE="filter"
    local ARG
    local -a ARGS
    while [[ $# > 0 ]]
    do
        KEY="$1"
        shift
        case $KEY in
            --table=*)
                TABLE="${KEY#*=}"
                ;;
            -t|--table)
                TABLE="$1"
                shift
                ;;
            *)
                ARGS+=("$KEY")
                ;;
        esac
    done
    local CHAIN="${ARGS[0]}"
    bb-assert 'test -n "$CHAIN"' "usage: $USAGE"
    if ! bb-iptables-chain? -t "$TABLE" "$CHAIN"
    then
        bb-log-info "creating chain $CHAIN in table $TABLE"
        iptables -t $TABLE -N "$CHAIN"
    fi
}

# Return rule number for rule with matching ID.
# If no rule matches, return "".
# Exit with error if multiple rules match given ID.
bb-iptables-rule-num() {
    local USAGE='bb-iptables-rule-num [-t,--table TABLE=filter] CHAIN ID'
    local TABLE="filter"
    local ARG
    local -a ARGS
    while [[ $# > 0 ]]
    do
        KEY="$1"
        shift
        case $KEY in
            --table=*)
                TABLE="${KEY#*=}"
                ;;
            -t|--table)
                TABLE="$1"
                shift
                ;;
            *)
                ARGS+=("$KEY")
                ;;
        esac
    done
    local CHAIN="${ARGS[0]}"
    local ID="${ARGS[1]}"
    bb-assert 'test -n "$CHAIN" -a -n "$ID"' "usage: $USAGE"
    NUMS=$(iptables -t $TABLE -nL "$CHAIN" --line-numbers | awk -v ID="$ID" '$0 ~ "/[*] " ID " [*]/" { print $1 }')
    bb-assert 'test $(echo $NUMS | wc -w) -lt 2' "rule '$ID' matches multiple rules: $NUMS"
    echo $NUMS
}

# Return checksum for matching rule.
bb-iptables-rule-hash() {
    local USAGE='bb-iptables-rule-hash [-t,--table TABLE=filter] CHAIN NUM'
    local TABLE="filter"
    local ARG
    local -a ARGS
    while [[ $# > 0 ]]
    do
        KEY="$1"
        shift
        case $KEY in
            --table=*)
                TABLE="${KEY#*=}"
                ;;
            -t|--table)
                TABLE="$1"
                shift
                ;;
            *)
                ARGS+=("$KEY")
                ;;
        esac
    done
    local CHAIN="${ARGS[0]}"
    local NUM="${ARGS[1]}"
    bb-assert 'test -n "$CHAIN" -a -n "$ID"' "usage: $USAGE"
    iptables -n -t $TABLE -L "$CHAIN" $NUM | md5sum | awk '{print $1}'
}

# Define rule in CHAIN and position NUM.
# If rule with matching ID exists, then update it.
# When NUM is negative, count from end of CHAIN (-1 == last rule).
bb-iptables-rule() {
    local USAGE='bb-iptables-rule [-t,--table TABLE=filter] [-n,--num NUM=-1] CHAIN ID IPTABLES_RULE...'
    local TABLE="filter"
    local NUM="-1"
    local ARG
    local -a ARGS
    while [[ $# > 0 ]]
    do
        KEY="$1"
        shift
        case $KEY in
            --table=*)
                TABLE="${KEY#*=}"
                ;;
            -t|--table)
                TABLE="$1"
                shift
                ;;
            --num=*)
                NUM="${KEY#*=}"
                ;;
            -n|--num)
                NUM="$1"
                shift
                ;;
            *)
                ARGS+=("$KEY")
                ;;
      esac
    done
    local CHAIN="${ARGS[0]}"
    local ID="${ARGS[1]}"
    unset ARGS[0] ARGS[1]
    bb-assert 'test -n "$CHAIN" -a -n "$ID"' "usage: $USAGE"
    local DEF="${ARGS[@]}"
    local RULE=$(bb-iptables-rule-num -t "$TABLE" "$CHAIN" "$ID")
    if [[ -n "$RULE" ]]
    then
        local RULEHASH=$(bb-iptables-rule-hash -t "$TABLE" "$CHAIN" $RULE)
        iptables -t $TABLE -R "$CHAIN" $RULE $DEF -m comment --comment "$ID"
        if [[ "$RULEHASH" != $(bb-iptables-rule-hash -t "$TABLE" "$CHAIN" $RULE) ]]
        then
            bb-log-info "replaced rule: $ID at $RULE"
        fi
    else
        TOTAL=$(( $(iptables -t $TABLE -nL "$CHAIN" | wc -l) - 2 ))
        if [[ $NUM -eq -1 ]]
        then
            # Handle append case specially.
            OP="-A"
            NUM=""
        else
            OP="-I"
            if [[ $NUM -lt 0 ]]
            then
                # Count from the end of the chain.
                NUM=$(( $TOTAL + $NUM + 2 ))
            fi
            if [[ $NUM -lt 1 ]]
            then
                # When there are no rules in chain or user specifies 0.
                NUM=1
            fi
        fi
        if [[ -n "$BB_DRY_RUN" ]]
        then
            echo "iptables -t $TABLE $OP '$CHAIN' $NUM $DEF -m comment --comment '$ID'"
        else
            bb-log-info "defining new rule: $ID at ${NUM:-END}"
            iptables -t $TABLE $OP "$CHAIN" $NUM $DEF -m comment --comment "$ID"
        fi
    fi
}

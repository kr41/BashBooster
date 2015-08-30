bb-iptables?() {
    bb-exe? iptables
}

bb-iptables-chain?() {
    local CHAIN="$1"
    bb-assert 'test -n "$CHAIN"' 'usage: bb-iptables-chain? CHAIN'
    iptables -nL "$CHAIN" > /dev/null 2> /dev/null
}

bb-iptables-chain() {
    local CHAIN="$1"
    if ! bb-iptables-chain? "$CHAIN"
    then
      iptables -N "$CHAIN"
    fi
}

bb-iptables-rule-num() {
    local CHAIN="${1}"
    local ID="$2"
    NUMS=$(iptables -nL "$CHAIN" --line-numbers | awk -v ID="$ID" '$0 ~ "/[*] " ID " [*]/" { print $1 }')
    bb-assert 'test $(echo $NUMS | wc -w) -lt 2' "rule '$ID' matches multiple rules: $NUMS"
    echo $NUMS
}

bb-iptables-rule() {
    local CHAIN="$1"
    local ID="$2"
    local NUM="$3"
    shift 3
    local DEF="$@"
    RULE=$(bb-iptables-rule-num "$CHAIN" "$ID")
    if test -n "$RULE"
    then
      iptables -R "$CHAIN" $RULE $DEF -m comment --comment "$ID"
    else
      if test $NUM -lt 0
      then
        NUM=$(( $(iptables -nL "$CHAIN" --line-numbers | tail -1 | awk '{ print $1 }') + $NUM ))
      fi
      if test $NUM -lt 1
      then
        NUM=1
      fi
      iptables -I "$CHAIN" $NUM $DEF -m comment --comment "$ID"
    fi
}

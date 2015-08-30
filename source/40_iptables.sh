# Manage iptables chains & rules, playing nice with existing rules.
# To reliably identify rules, an "ID" is required for each rule.  It
# must be unique to the chain.

# True if `iptables` is executable
bb-iptables?() {
    bb-exe? iptables
}

# True if given chain exists.
bb-iptables-chain?() { # (CHAIN)
    local CHAIN="$1"
    bb-assert 'test -n "$CHAIN"' 'usage: bb-iptables-chain? CHAIN'
    iptables -nL "$CHAIN" > /dev/null 2> /dev/null
}

# Create chain if does not already exist.
bb-iptables-chain() { # (CHAIN)
    local CHAIN="$1"
    if ! bb-iptables-chain? "$CHAIN"
    then
      iptables -N "$CHAIN"
    fi
}

# Return rule number for rule with matching ID.
# If no rule matches, return "".
# Exit with error if multiple rules match given ID.
bb-iptables-rule-num() { # (CHAIN, ID)
    local CHAIN="${1}"
    local ID="$2"
    NUMS=$(iptables -nL "$CHAIN" --line-numbers | awk -v ID="$ID" '$0 ~ "/[*] " ID " [*]/" { print $1 }')
    bb-assert 'test $(echo $NUMS | wc -w) -lt 2' "rule '$ID' matches multiple rules: $NUMS"
    echo $NUMS
}

# Define rule in CHAIN and position NUM.
# If rule with matching ID exists, then update it.
# When NUM is negative, count from end of CHAIN (-1 == last rule).
bb-iptables-rule() { # (CHAIN, ID, NUM)
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
      TOTAL=$(( $(iptables -nL "$CHAIN" | wc -l) - 2 ))
      if test $NUM -eq -1
      then
        # Handle append case specially.
        OP="-A"
        NUM=""
      else
        OP="-I"
        if test $NUM -lt 0
        then
          # Count from the end of the chain.
          NUM=$(( $TOTAL + $NUM + 2 ))
        fi
        if test $NUM -lt 1
        then
          # When there are no rules in chain or user specifies 0.
          NUM=1
        fi
      fi
      iptables $OP "$CHAIN" $NUM $DEF -m comment --comment "$ID"
    fi
}

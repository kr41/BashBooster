# Manage iptables chains & rules, playing nice with existing rules.
# To reliably identify rules, an "ID" is required for each rule.  It
# must be unique to the chain.

# Example Usage:
#
# bb-iptables-chain FOO
# bb-iptables-rule FOO id=tcp:2 -1 -p tcp --dport 2 -j ACCEPT # Append some rules.
# bb-iptables-rule FOO id=tcp:4 -1 -p tcp --dport 4 -j ACCEPT
# bb-iptables-rule FOO id=tcp:3 -2 -p tcp --dport 3 -j ACCEPT # Add just before the end.
# bb-iptables-rule FOO id=tcp:1 1 -p tcp --dport 1 -j ACCEPT  # Insert at beginning.

# NOTE: Can run with `BB_DRY_RUN` set to get a sense of what it might do but
# it's not 100% accurate since:
#  a) depends on chains being defined
#  b) rule numbers/positions will change


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
      if test -n "$BB_DRY_RUN"
      then
        echo "iptables -N '$CHAIN'"
      else
        iptables -N "$CHAIN"
      fi
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
      CMD="iptables -R '$CHAIN' $RULE $DEF -m comment --comment '$ID'"
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
      CMD="iptables $OP '$CHAIN' $NUM $DEF -m comment --comment '$ID'"
    fi
    if test -n "$BB_DRY_RUN"
    then
      echo $CMD
    else
      eval $CMD
    fi
}

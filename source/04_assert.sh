BB_ASSERT_ERROR=3

bb-assert() {
    # Local vars are prefixed to avoid conflicts with ASSERTION expression
    local __ASSERTION="$1"
    local __MESSAGE="${2-Assertion error '$__ASSERTION'}"

    if ! eval "$__ASSERTION"
    then
        bb-exit $BB_ASSERT_ERROR "$__MESSAGE"
    fi
}

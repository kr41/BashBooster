declare -A BB_EXT_BODIES

bb-ext-python() {
    local NAME="$1"
    BB_EXT_BODIES[$NAME]="$( cat )"

    eval "$NAME() { python -c \"\${BB_EXT_BODIES[$NAME]}\" \"\$@\"; }"
}

# This variable stores parameters passed during invokation of augtool.
bb-var BB_EXT_AUGEAS_PARAMS ""

bb-ext-augeas() {
    local NAME="$1"
    BB_EXT_BODIES[$NAME]="$( cat )"

    eval "$NAME() { cat <<EOF | augtool "$BB_EXT_AUGEAS_PARAMS"
\${BB_EXT_BODIES[$NAME]}
EOF
}"
}


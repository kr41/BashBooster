declare -A BB_EXT_BODIES

bb-ext-python() {
    local NAME="$1"
    BB_EXT_BODIES[$NAME]="$( cat )"

    eval "$NAME() { python -c \"\${BB_EXT_BODIES[$NAME]}\" \"\$@\"; }"
}

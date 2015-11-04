
# This variable can be used to provide additional commands to run by Augeas.
bb-var BB_AUGEAS_EXTRA_COMMANDS ""

bb-augeas?() {
    bb-exe? augtool
}

bb-augeas-get-path() {
    local ABSOLUTE_FILE_PATH="$1"
    local SETTING="$2"

    echo "/files$ABSOLUTE_FILE_PATH/$SETTING"
}

bb-augeas-file-supported?() {
    local ABSOLUTE_FILE_PATH="$1"

    # Define the helper function
    bb-ext-augeas 'bb-augeas-file-supported?-helper' <<EOF
$BB_AUGEAS_EXTRA_COMMANDS
print '/augeas/files$ABSOLUTE_FILE_PATH/path'
EOF

    # Run the helper function
    local OUTPUT="$(bb-augeas-file-supported?-helper)"
    bb-error? && bb-assert false "Failed to execute augeas"

    # Check output
    # When file is supported, the output is in the form:
    #     /augeas/files/<File path>/path = "/files/<File path>"
    [[ "$OUTPUT" == "/augeas/files/"* ]]
}

bb-augeas-get() {
    local ABSOLUTE_FILE_PATH="$1"
    local SETTING="$2"
    local AUG_PATH="$(bb-augeas-get-path "$ABSOLUTE_FILE_PATH" "$SETTING")"

    # Validate the specified file
    [ -f "$ABSOLUTE_FILE_PATH" ] || { bb-log-error "File '$ABSOLUTE_FILE_PATH' not found"; return 1; }
    [ -r "$ABSOLUTE_FILE_PATH" ] || { bb-log-error "File '$ABSOLUTE_FILE_PATH' is not readable"; return 1; }
    bb-augeas-file-supported? "$ABSOLUTE_FILE_PATH" || { bb-log-error "Cannot get value from unsupported file '$ABSOLUTE_FILE_PATH'"; return 1; }

    # Define the helper function
    bb-ext-augeas 'bb-augeas-get-helper' <<EOF
$BB_AUGEAS_EXTRA_COMMANDS
get '$AUG_PATH'
EOF

    # Run the helper function
    local VALUE="$(bb-augeas-get-helper)"
    if bb-error?
    then
        bb-log-error "An error occured while getting value of '$SETTING' from $ABSOLUTE_FILE_PATH"
        return $BB_ERROR
    fi

    # Handle the result
    if [[ $VALUE == *" = "* ]]
    then
         # Value of the setting has been found
         # Output is in the form /files/.../<Setting> = Value
         VALUE="${VALUE#*=}"
         VALUE="${VALUE// }" # Remove leading spaces
         VALUE="${VALUE%%}"  # Remove trailing spaces
    elif [[ $VALUE == *" (none)"* ]]
    then
        # Setting has empty value
        VALUE=""
    else
        # Setting not found/set
        VALUE=""
    fi

    echo "$VALUE"
}

bb-augeas-match?() {
    local ABSOLUTE_FILE_PATH="$1"
    local SETTING="$2"
    local VALUE="$3"
    local AUG_PATH=$(bb-augeas-get-path "$ABSOLUTE_FILE_PATH" "$SETTING")

    # Validate the specified file
    [ -f "$ABSOLUTE_FILE_PATH" ] || { bb-log-error "File '$ABSOLUTE_FILE_PATH' not found"; return 1; }
    [ -r "$ABSOLUTE_FILE_PATH" ] || { bb-log-error "File '$ABSOLUTE_FILE_PATH' is not readable"; return 1; }
    bb-augeas-file-supported? "$ABSOLUTE_FILE_PATH" || { bb-log-error "Cannot match value from unsupported file '$ABSOLUTE_FILE_PATH'"; return 1; }

    # Define the helper function
    bb-ext-augeas 'bb-augeas-match-helper' <<EOF
$BB_AUGEAS_EXTRA_COMMANDS
match '$AUG_PATH' "$VALUE"
EOF

    # Run the helper function
    local OUTPUT="$(bb-augeas-match-helper)"
    if bb-error?
    then
        bb-log-error "An error occured while verifying if '$SETTING' matches '$VALUE' ($AUG_PATH)"
        return 0
    fi

    # Check output
    # When there is a match, the output is in the form:
    #     /files/<File path>
    [[ "$OUTPUT" == "/files/"* ]]
}

bb-augeas-set() {
    local ABSOLUTE_FILE_PATH="$1"
    local SETTING="$2"
    local VALUE="$3"
    local AUG_PATH=$(bb-augeas-get-path "$ABSOLUTE_FILE_PATH" "$SETTING")
    shift 3

    # Validate the specified file
    [ -f "$ABSOLUTE_FILE_PATH" ] || { bb-log-error "File '$ABSOLUTE_FILE_PATH' not found"; return 1; }
    [ -w "$ABSOLUTE_FILE_PATH" ] || { bb-log-error "File '$ABSOLUTE_FILE_PATH' is not writeable"; return 1; }
    bb-augeas-file-supported? "$ABSOLUTE_FILE_PATH" || { bb-log-error "Cannot set value to unsupported file '$ABSOLUTE_FILE_PATH'"; return 1; }

    # Define the helper function
    bb-ext-augeas 'bb-augeas-set-helper' <<EOF
$BB_AUGEAS_EXTRA_COMMANDS
set "$AUG_PATH" "$VALUE"
save
EOF

    # Run the helper function
    local OUTPUT=$(bb-augeas-set-helper)
    if bb-error?
    then
        bb-log-error "An error occured while setting value of '$SETTING' to '$VALUE' ($ABSOLUTE_FILE_PATH)"
        return $BB_ERROR
    fi

    # Raise events if file changed
    if [[ "$OUTPUT" == "Saved "* ]]
    then
        bb-event-delay "$@"
        bb-event-fire "bb-augeas-file-changed" "$ABSOLUTE_FILE_PATH"
    fi
}


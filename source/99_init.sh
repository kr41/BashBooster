bb-workspace-init
bb-tmp-init
bb-event-init
bb-download-init
bb-flag-init

bb-cleanup() {
    bb-event-fire bb-cleanup

    bb-flag-cleanup
    bb-event-cleanup
    bb-tmp-cleanup
    bb-workspace-cleanup
}

trap bb-cleanup EXIT

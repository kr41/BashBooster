bb-log-init

bb-workspace-init
bb-tmp-init
bb-event-init
bb-download-init

bb-cleanup() {
    bb-event-fire bb-cleanup

    bb-event-cleanup
    bb-tmp-cleanup
    bb-workspace-cleanup
}

trap bb-cleanup EXIT

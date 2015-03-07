#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_USE_COLOR=true
BB_WORKSPACE='/var/bb-workspace'
source ../../build/bashbooster.sh


PROJECT_DIR='/home/vagrant/Projects/TraversalKitExampleApp'


bb-log-info 'Installing Bash Booster'
../../build/install.sh


bb-log-info 'Installing system packages'
bb-apt-install 'mercurial' 'python-virtualenv'


bb-log-info 'Cloning project'
[[ ! -d "$PROJECT_DIR" ]] && \
    sudo -iu vagrant hg clone \
        'https://kr41@bitbucket.org/kr41/traversalkitexampleapp' \
        "$PROJECT_DIR"


bb-log-info 'Syncing task file'
bb-sync-file \
    "$PROJECT_DIR/bb-tasks.sh" \
    '/vagrant/examples/task-runner/bb-tasks.sh'
chown vagrant:vagrant "$PROJECT_DIR/bb-tasks.sh"

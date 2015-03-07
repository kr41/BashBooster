#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_LEVEL='DEBUG'
BB_LOG_USE_COLOR=true
BB_WORKSPACE='/var/bb-workspace'
source ../../build/bashbooster.sh


bb-log-info 'Installing Bash Booster'
../../build/install.sh

bb-apt-install 'mercurial' 'python-virtualenv'


[[ ! -d '/home/vagrant/Projects' ]] && \
    mkdir 'home/vagrant/Projects'
[[ ! -d '/home/vagrant/Projects/TraversalKitExampleApp' ]] && \
    hg clone \
        'https://kr41@bitbucket.org/kr41/traversalkitexampleapp' \
        '/home/vagrant/Projects/TraversalKitExampleApp'

bb-sync-file \
    '/home/vagrant/Projects/TraversalKitExampleApp/bb-tasks.sh' \
    '/vagrant/examples/task-runner/bb-tasks.sh'

chown -R vagrant:vagrant '/home/vagrant/Projects'

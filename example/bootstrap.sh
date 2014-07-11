#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_USE_COLOR=true
BB_WORKSPACE='/var/bb-workspace'
source ../bashbooster.sh

BB_LOG_LEVEL='DEBUG'

bb-log-info "Installing system requirements"
if bb-apt?
then
    bb-apt-install nginx python-virtualenv
elif bb-yum?
then
    EPEL_REPO=`bb-download http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm`
    bb-yum-repo? epel || rpm -ivh "$EPEL_REPO"
    bb-yum-install nginx python-virtualenv
    chkconfig nginx on
fi
service nginx start

bb-log-info "Preparing environment"
if [[ ! -d "$BB_WORKSPACE/docs" ]]
then
    mkdir "$BB_WORKSPACE/docs"
fi
if [[ ! -d "$BB_WORKSPACE/www" ]]
then
    mkdir "$BB_WORKSPACE/www"
fi
if [[ ! -d "$BB_WORKSPACE/virtualenv" ]]
then
    virtualenv "$BB_WORKSPACE/virtualenv"
fi
pip="$BB_WORKSPACE/virtualenv/bin/pip"
python="$BB_WORKSPACE/virtualenv/bin/python"

bb-log-info "Creating event listeners"
bb-event-listen reload-server 'service nginx restart'
bb-event-listen rebuild-docs "$python $BB_WORKSPACE/docs/build.py"
bb-event-listen update-deps "$pip install -r $BB_WORKSPACE/docs/requirements.txt"

bb-log-info "Synchronizing data"
bb-sync-file "$BB_WORKSPACE/docs/build.py" '/vagrant/docs/build.py'
bb-sync-file "$BB_WORKSPACE/docs/requirements.txt" '/vagrant/docs/requirements.txt' update-deps
bb-sync-file "$BB_WORKSPACE/docs/layout.mako" '/vagrant/docs/layout.mako' rebuild-docs
bb-sync-file "$BB_WORKSPACE/docs/index.md" '/vagrant/docs/index.md' rebuild-docs
bb-sync-file "$BB_WORKSPACE/www/index.html" "$BB_WORKSPACE/docs/index.html"

NGINX_CONF=`bb-tmp-file`
bb-template "nginx.conf.bbt" > "$NGINX_CONF"
if [[ -f '/etc/nginx/sites-available/default' ]]
then
    bb-sync-file '/etc/nginx/sites-available/default' "$NGINX_CONF" reload-server
elif [[ -f '/etc/nginx/conf.d/default.conf' ]]
then
    bb-sync-file '/etc/nginx/conf.d/default.conf' "$NGINX_CONF" reload-server
fi

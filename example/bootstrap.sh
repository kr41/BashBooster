#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_LEVEL='DEBUG'
BB_LOG_USE_COLOR=true
BB_WORKSPACE='/var/bb-workspace'
source ../bashbooster.sh


###############################################################################

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


###############################################################################

bb-log-info "Preparing environment"

service nginx start
[[ -d "$BB_WORKSPACE/docs" ]]       || mkdir      "$BB_WORKSPACE/docs"
[[ -d "$BB_WORKSPACE/www" ]]        || mkdir      "$BB_WORKSPACE/www"
[[ -d "$BB_WORKSPACE/virtualenv" ]] || virtualenv "$BB_WORKSPACE/virtualenv"

pip="$BB_WORKSPACE/virtualenv/bin/pip"
python="$BB_WORKSPACE/virtualenv/bin/python"


###############################################################################

bb-log-info "Creating event listeners"

reload-server() {
    service nginx restart
}
update-python-deps() {
    $pip install -r $BB_WORKSPACE/docs/requirements.txt
}
rebuild-site() {
    $python $BB_WORKSPACE/docs/build.py
    bb-sync-dir "$BB_WORKSPACE/www" "$BB_WORKSPACE/docs/www"
}
bb-event-on reload-server      reload-server
bb-event-on update-python-deps update-python-deps
bb-event-on rebuild-site       rebuild-site


###############################################################################

bb-log-info "Synchronizing data"

bb-sync-dir  "$BB_WORKSPACE/www"                   '/vagrant/docs/www'
bb-sync-file "$BB_WORKSPACE/docs/requirements.txt" '/vagrant/docs/requirements.txt' update-python-deps
bb-sync-file "$BB_WORKSPACE/docs/layout.mako"      '/vagrant/docs/layout.mako'      rebuild-site
bb-sync-file "$BB_WORKSPACE/docs/index.md"         '/vagrant/docs/index.md'         rebuild-site
bb-sync-file "$BB_WORKSPACE/docs/build.py"         '/vagrant/docs/build.py'         rebuild-site

NGINX_CONF=`bb-tmp-file`
bb-template "nginx.conf.bbt" > "$NGINX_CONF"
if [[ -f '/etc/nginx/sites-available/default' ]]
then
    bb-sync-file '/etc/nginx/sites-available/default' "$NGINX_CONF" reload-server
elif [[ -f '/etc/nginx/conf.d/default.conf' ]]
then
    bb-sync-file '/etc/nginx/conf.d/default.conf'     "$NGINX_CONF" reload-server
fi

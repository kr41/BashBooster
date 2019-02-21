#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_LOG_LEVEL='DEBUG'
BB_LOG_USE_COLOR=true
BB_WORKSPACE='/var/bb-workspace'
source ../../build/bashbooster.sh


###############################################################################

bb-log-info "Installing system requirements"

if bb-apt?
then
    bb-apt-install nginx python-virtualenv
elif bb-yum?
then
    bb-exe? wget || bb-yum-install wget

    EPEL_REPO="$( bb-download http://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm )"
    bb-yum-repo? epel || rpm -ivh "$EPEL_REPO"

    bb-event-on 'bb-package-installed' 'post-install'
    post-install() {
        local PACKAGE="$1"
        case "$PACKAGE" in
            "nginx")
                chkconfig nginx on
                service nginx start
                ;;
        esac
    }
    bb-yum-install nginx python-virtualenv
fi


###############################################################################

bb-log-info "Preparing environment"

[[ -d "$BB_WORKSPACE/docs/www" ]]   || mkdir -p   "$BB_WORKSPACE/docs/www"
[[ -d "$BB_WORKSPACE/virtualenv" ]] || virtualenv "$BB_WORKSPACE/virtualenv"

pip="$BB_WORKSPACE/virtualenv/bin/pip"
python="$BB_WORKSPACE/virtualenv/bin/python"


###############################################################################

bb-log-info "Creating event listeners"

bb-event-on 'webserver-updated' 'on-webserver-updated'
on-webserver-updated() {
    systemctl restart nginx
}

bb-event-on 'builder-updated' 'on-builder-updated'
on-builder-updated() {
    $pip install -r $BB_WORKSPACE/docs/requirements.txt
}

bb-event-on 'site-updated' 'on-site-updated'
on-site-updated() {
    $python $BB_WORKSPACE/docs/build.py
}


###############################################################################

bb-log-info "Synchronizing data"

bb-sync-dir     "$BB_WORKSPACE/docs/www/css"          '/vagrant/docs/www/css'
bb-sync-file    "$BB_WORKSPACE/docs/requirements.txt" '/vagrant/docs/requirements.txt' builder-updated
bb-sync-dir  -o "$BB_WORKSPACE/docs/"                 '/vagrant/docs/'                 site-updated
bb-sync-file    "$BB_WORKSPACE/CHANGES.md"            '/vagrant/CHANGES.md'            site-updated
bb-sync-file    "$BB_WORKSPACE/VERSION.txt"           '/vagrant/VERSION.txt'           site-updated


if [[ -f '/etc/nginx/sites-available/default' ]]
then
    NGINX_CONF="$( bb-tmp-file )"
    bb-template "nginx.conf.bbt" > "$NGINX_CONF"
    bb-sync-file '/etc/nginx/sites-available/default' "$NGINX_CONF" webserver-updated
else
    bb-sync-dir -o '/usr/share/nginx/html' "$BB_WORKSPACE/docs/www"
fi

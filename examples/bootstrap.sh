#!/bin/bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

BB_WORKSPACE='/var/bb-workspace'
source ../bashbooster.sh

if bb-apt?
then
    bb-apt-install nginx
elif bb-yum?
then
    EPEL_REPO=`bb-download http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm`
    bb-yum-repo? epel || rpm -ivh "$EPEL_REPO"
    bb-yum-install nginx
    chkconfig nginx on
fi
service nginx start

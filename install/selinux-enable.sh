#!/bin/bash

SESTATUS=`/usr/sbin/sestatus | /bin/grep 'permissive' > /dev/null`
if [ "$?" == "0" ]; then
    if [ -d /selinux ]; then
        /bin/echo '1' > /selinux/enforce
    elif [ -d /sys/fs/selinux ]; then
        /bin/echo '1' > /sys/fs/selinux/enforce
    fi
fi
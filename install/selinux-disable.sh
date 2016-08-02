#!/bin/bash

SESTATUS=`/usr/sbin/sestatus | /bin/grep 'enforcing' > /dev/null`
if [ "$?" == "0" ]; then
    if [ -d /selinux ]; then
        /bin/echo '0' > /selinux/enforce
    elif [ -d /sys/fs/selinux ]; then
        /bin/echo '0' > /sys/fs/selinux/enforce
    fi
fi

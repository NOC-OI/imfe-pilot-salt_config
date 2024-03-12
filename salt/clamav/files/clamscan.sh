#!/bin/bash

/usr/bin/clamscan --cross-fs=no --infected --log=/var/log/clamav/clamav.log -r / 2>&1 |  grep -v "^LibClamAV Warning: cli_scanxz: decompress file size exceeds limit" > /tmp/clamscan.out

count=`cat /tmp/clamscan.out | grep "^Infected files:" | awk '{print $3}'`

if [ "$count" -gt "0" ] ; then
    cat /tmp/clamscan.out
fi

rm /tmp/clamscan.out


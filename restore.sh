#!/bin/bash

cp /backups/base/ /backups/output -R
if [[ -d /backups/increment ]]; then
    xtrabackup --prepare --apply-log-only --target-dir=/backups/output
    xtrabackup --prepare --target-dir=/backups/output --incremental-dir=/backups/increment
else
    xtrabackup --prepare --target-dir=/backups/output
fi

echo "Backup is now in /backups/output"
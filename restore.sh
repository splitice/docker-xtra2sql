#!/bin/bash

set -x

rm /backups/output/* -R -f
cp /backups/base/ /backups/output/db -R
if [[ -d /backups/increment ]]; then
    xtrabackup --prepare --apply-log-only --target-dir=/backups/output
    xtrabackup --prepare --target-dir=/backups/output/db --incremental-dir=/backups/increment
else
    xtrabackup --prepare --target-dir=/backups/output/db
fi

echo "SQL files are now in /backups/output/sql/table.sql"
echo "Importable files are now in /backups/output/db"
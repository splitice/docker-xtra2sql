#!/bin/bash

set -x

rm /backups/output/* -R -f
cp /backups/base/ /backups/output/db -R
if [[ -d /backups/increment ]]; then
    xtrabackup --prepare --apply-log-only --target-dir=/backups/output/db
    xtrabackup --prepare --target-dir=/backups/output/db --incremental-dir=/backups/increment
else
    xtrabackup --prepare --target-dir=/backups/output/db
fi

echo "Starting MySQL"
/usr/sbin/mysqld --datadir /backups/output/db &
sleep 15

mkdir -p /backups/output/sql
mysqldump --tab=/backups/output/sql --all-databases

echo "==[ Finished ]=="
echo "SQL files are now in /backups/output/sql/table.sql"
echo "Importable files are now in /backups/output/db"
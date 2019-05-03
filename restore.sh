#!/bin/bash

set -x

if [[ -d /backups/output/db ]]; then
    if [[ -f "/backups/output/db/xtrabackup_checkpoints" ]]; then
        if [[ $(md5sum /backups/base/xtrabackup_checkpoints | awk '{print $1}') == $(md5sum /backups/output/db/xtrabackup_checkpoints | awk '{print $1}') ]]; then
            echo "Previous backup supplied"
        else
            rm /backups/output/db -R -f
        fi
    else
        rm /backups/output/db -R -f
    fi
fi

if [[ -d /backups/output/sql ]]; then
    rm /backups/output/sql -R -f
fi

if [[ ! -f "/backups/output/db/xtrabackup_checkpoints" ]]; then
    cp /backups/base/ /backups/output/db -R
fi

if [[ -d /backups/increment ]]; then
    xtrabackup --decompress --target-dir=/backups/output/db
    xtrabackup --decompress --target-dir=/backups/output/increment
    xtrabackup --prepare --apply-log-only --target-dir=/backups/output/db
    xtrabackup --prepare --target-dir=/backups/output/db --incremental-dir=/backups/increment
else
    xtrabackup --decompress --target-dir=/backups/output/db
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
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

function decompress_if_needed {
    path="$1"
    if [[ -f "$path/ibdata1.qp" && ! -f "$path/ibdata1" ]]; then
        innobackupex --decompress "$path"
        find "$path" -iname '*.qp' -delete
    elif [[ -f "$path/ibdata1.delta.qp" && ! -f "$path/ibdata1.delta" ]]; then
        innobackupex --decompress "$path"
        find "$path" -iname '*.qp' -delete
    fi
}

if [[ -d /backups/increment ]]; then
    decompress_if_needed /backups/output/db
    decompress_if_needed /backups/increment
    innobackupex --apply-log --redo-only /backups/output/db
    innobackupex --apply-log /backups/output/db --incremental --incremental-basedir=/backups/increment
else
    decompress_if_needed /backups/output/db
    innobackupex --apply-log /backups/output/db
fi

#remove mysql user
sed '/^user/d' /etc/mysql/my.cnf > /tmp/a
mv /tmp/a /etc/mysql/my.cnf

log_file_size=$(cat /backups/output/db/backup-my.cnf | grep log_file_size | awk -F= '{print $2}')

echo "Starting MySQL"
mkdir -p /var/run/mysqld
chown mysql:mysql -R /var/run/mysqld /backups/output/
/usr/sbin/mysqld --skip-grant-tables --datadir=/backups/output/db --innodb-buffer-pool-size=128M --innodb_log_buffer_size=64M --innodb-read-only=1 --event-scheduler=disabled --bind-address=127.0.0.1 --port=599 --user=root --innodb-log-file-size=$log_file_size &

sleep 10


echo 'show databases' | mysql -h127.0.0.1 -P599 | grep -v mysql | grep -v information_schema | grep -v performance_schema | tail -n+2 | while read -r db ; do
    mkdir -p /backups/output/sql/$db
    mysqldump -h127.0.0.1 -P599  --tab=/backups/output/sql/$db $db
done

echo "==[ Finished ]=="
echo "SQL files are now in /backups/output/sql/table.sql"
echo "Importable files are now in /backups/output/db"
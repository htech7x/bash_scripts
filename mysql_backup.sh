#!/bin/sh

#CREDENTIALS="--user=DBUSER --password=DBUSERPASS"
NOW=`date +%Y-%m-%d_%H-%M-%S`
BACKUP_DIR="/root/backup/"
DATA_DIR=$NOW
TMPFILE="/tmp/innobackupex-runner.$$.tmp"


if [ ! -d $BACKUP_DIR ]; then
    mkdir $BACKUP_DIR
fi

echo "Starting backup..."

#innobackupex --host localhost $CREDENTIALS --no-timestamp ${BACKUP_DIR}${DATA_DIR} > $TMPFILE 2>&1
innobackupex --host localhost --no-timestamp ${BACKUP_DIR}${DATA_DIR} > $TMPFILE 2>&1

if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ] ; then
    echo "Backup filed. For more details see log file" $TMPFILE
    exit 1
fi
rm -f $TMPFILE

#innobackupex --host localhost $CREDENTIALS --apply-log ${BACKUP_DIR}${DATA_DIR} > $TMPFILE 2>&1
innobackupex --host localhost --apply-log ${BACKUP_DIR}$DATA_DIR > $TMPFILE 2>&1

if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ] ; then
    echo "--apply-log filed. For more details see log file" $TMPFILE
    exit 1
fi
rm -f $TMPFILE

echo "Archiving backup..."
tar -cvzf ${BACKUP_DIR}$DATA_DIR.tar.gz ${BACKUP_DIR}$DATA_DIR
rm -rf ${BACKUP_DIR}$DATA_DIR

echo "Backup complete"

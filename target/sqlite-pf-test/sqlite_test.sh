#!/bin/sh

# Execute pf-test.sql and pf-test_grow.sql scripts on
# corresponding pf-test.db and pf-test_grow.db SQLite databases.
#
# This script is invoked by pf-test.sh to create SQLite DB load
# at the time of power failure.
#
# Note that it is necessary to run sqlite_check.sh *before* this script.
#
# Usage: sqlite_test.sh <directory>
#
# -- dmitry.semyonov@cogentembedded.com

SCRIPTDIR=`dirname $0`
MOUNT_POINT=$1

N=0
while true; do
        N=$((N+1))
	echo "`date -Iseconds` SQLite test iteration $N"
	sqlite3 -init $SCRIPTDIR/pf-test.sql $MOUNT_POINT/pf-test.db .quit &
	sqlite3 -init $SCRIPTDIR/pf-test_grow.sql $MOUNT_POINT/pf-test_grow.db .quit &
	wait
done

#!/bin/sh -e

# Creates test databases on the first run.
# Performs database integrity checks.
#
# Usage: sqlite_check.sh <directory>
#
# Return: 0 on success.
#         Otherwise returns non-zero and logs failure reason.
#
# -- dmitry.semyonov@cogentembedded.com

SCRIPTDIR=`dirname $0`
MOUNT_POINT=$1

test -s $MOUNT_POINT/pf-test.db || cp $SCRIPTDIR/pf-test.db $MOUNT_POINT/pf-test.db
test -s $MOUNT_POINT/pf-test_grow.db || cp $SCRIPTDIR/pf-test.db $MOUNT_POINT/pf-test_grow.db

set -x # log commands
sqlite3 $MOUNT_POINT/pf-test.db 'pragma integrity_check'
sqlite3 $MOUNT_POINT/pf-test_grow.db 'pragma integrity_check'
set +x

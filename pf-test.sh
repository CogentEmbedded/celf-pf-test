#!/bin/bash

# Filesystems verification under power-failure conditions.
#
# -- dmitry.semyonov@cogentembedded.com

set -x # show script settings on console

EMAIL="" # may be empty
TARGET=root@10.0.0.103  # put target IP or domain name here

# TARGET_TESTS must have corresponding target_test_*() and data_check_*()
# functions defined below
declare -a TARGET_TESTS=(fsstress sqlite)
declare -a TARGET_TIMEOUTS=(30    30)
# Timeouts should not be too large to allow more power cycles.
# At the same time, they should not be too small
# to catch different states of target test running in background.

declare -a FILESYSTEMS=(f2fs)
declare -a PARTITIONS=(/dev/mmcblk0p3)

# MOUNT_OPTIONS are selected randomly, (in contrast to
# sequential selection of TARGET_TESTS and FILESYSTEMS)
MOUNT_OPTIONS_ext4=("" "-o nobarrier")
MOUNT_OPTIONS_btrfs=("" "-o ssd,noatime")
MOUNT_OPTIONS_f2fs=("-o discard,noatime")

MOUNT_POINT="/media/mmc"
POWER_CMD="`dirname $0`/power-cycle.apc"

# If you plan to run multiple scripts in parallel, then start them from
# different directories, or improve log name creation to suit your needs.
TEST_LOG="test.log"
TARGET_TEST_LOG="target.log"

set +x # stop tracing bash commands


#-------------------------
# See TARGET_TESTS definition
# It definitely makes sence to implement data_check_*() if you know
# how to check data integrity for files created by corresponding target_test_*()

target_test_fsstress()
{
    ssh $TARGET "mkdir -p $MOUNT_POINT/fsstress && fsstress -w -d $MOUNT_POINT/fsstress -l 0 -n 100 -p 100 -s urandom" >> $TARGET_TEST_LOG 2>&1 &
}
data_check_fsstress()
{
    ssh $TARGET "rm -rf $MOUNT_POINT/fsstress" >> $TARGET_TEST_LOG 2>&1
    return 0
}


target_test_sqlite()
{
    ssh $TARGET "sqlite-pf-test/sqlite_test.sh $MOUNT_POINT" >> $TARGET_TEST_LOG 2>&1 &
}
data_check_sqlite()
{
    ssh $TARGET "sqlite3 $MOUNT_POINT/test.db 'pragma integrity_check'" >> $TEST_LOG 2>&1
    rc1=$?
    ssh $TARGET "sqlite3 $MOUNT_POINT/test_grow.db 'pragma integrity_check'" >> $TEST_LOG 2>&1
    rc2=$?
    [ $rc1 -ne 0 ] && abort $rc1 "test.db integrity check failed"
    [ $rc2 -ne 0 ] && abort $rc2 "test_grow.db integrity check failed"
}


#-------------------------
# Helper functions

abort()
{
    disk_info
    err "$1: $2"
    err "*** Test FAILED ***"
    [ -n "$EMAIL" ] && echo | mail -s "$0: $1" $EMAIL
    exit 1
}

# $1 - message
log()
{
    echo -e "`date -Is` $1" >> $TEST_LOG
}

err()
{
    cur_date=`date -Is`
    echo -e "$cur_date $1" | tee -a $TEST_LOG
}

fs_mount()
{
    log "fs_mount started"

    log "fs_mount mount $mount_args $partition $MOUNT_POINT"
    ssh $TARGET "sync; time mount $mount_args $partition $MOUNT_POINT" >> $TEST_LOG 2>&1

    log "fs_mount finished"
}

fs_umount()
{
    log "fs_umount started"

    ssh $TARGET "sync; time umount $MOUNT_POINT" >> $TEST_LOG 2>&1

    log "fs_umount finished"
}

disk_info()
{
    # Collect Flash wear statistics
    #ssh -o ConnectTimeout=3 -o ServerAliveInterval=3 $TARGET 'smart-info |grep -v "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"' >> $TEST_LOG 2>&1
    return 0
}

fs_check()
{
    log "fs_check started"

    case "$filesystem" in
        ext3)  fsck_args="-vpf"; max_rc=1 ;; # rc=1 after journal recovery
        ext4)  fsck_args="-vpf"; max_rc=1 ;; # rc=1 after journal(?) recovery even when FS is tuned not to use journal
        btrfs) fsck_args=""; max_rc=0 ;;
        f2fs)  fsck_args=""; max_rc=0 ;;
    esac

    ssh $TARGET "sync; time fsck.$filesystem $fsck_args $partition" >> $TEST_LOG 2>&1
    rc=$?
    [ $rc -gt $max_rc ] && abort $rc "FS integrity check failed"

    log "fs_check finished"
}

data_check()
{
    log "data_check started"

    ssh $TARGET "df -h $MOUNT_POINT" >> $TEST_LOG 2>&1
    data_check_$target_test

    log "data_check finished"
}

start_target_test()
{
    log "start_target_test ($target_test) started"

    # & at the end is important!
    echo -e "\n`date -Is` --- cycle $cycle ---" >> $TARGET_TEST_LOG
    target_test_$target_test

    log "start_target_test finished"
}

power_cycle()
{
    log "power_cycle started"

    $POWER_CMD > /dev/null

    log "power_cycle finished"
}

wait_target_up()
{
    max_wait_cycles=60 # 1 minute
    while ! ssh -o ConnectTimeout=3 -o ServerAliveInterval=3 $TARGET true 2>/dev/null; do
        echo -n .
        sleep 1;
        let max_wait_cycles--
        if [ $max_wait_cycles -eq 0 ]; then
            abort 0 "wait_target_up() timed out."
            #err "wait_target_up() timed out. Retrying power-cycle..."
            power_cycle
            max_wait_cycles=600 # 10 minutes
        fi
    done
    echo -n "!"
    log "target ready\n"
}

wait_target_down()
{
    echo -n "x"
    while true; do
        ssh -o ConnectTimeout=10 -o ServerAliveInterval=5 $TARGET sleep 60 2>/dev/null
        rc=$?
        if [ $rc -eq 0 ]; then
            abort 0 "wait_target_down() timed out."
            #err "wait_target_down() timed out. Retrying power-cycle..."
            power_cycle
        else
            break
        fi
    done
    echo -n "!"
}

set_global_vars()
{
    target_test=${TARGET_TESTS[test_num]}
    max_timeout=${TARGET_TIMEOUTS[test_num]}

    filesystem=${FILESYSTEMS[fs_num]}
    partition=${PARTITIONS[fs_num]}

    # Randomly select mount options from relevant MOUNT_OPTIONS_<fs> variables
    fs_options_max=`eval echo \\${#MOUNT_OPTIONS_$filesystem[@]}`
    if [ $fs_options_max -gt 0 ]; then
        let fs_option_idx=$RANDOM%$fs_options_max
        mount_args=`eval echo \\${MOUNT_OPTIONS_$filesystem[fs_option_idx]}`
    else
        mount_args=
    fi

    # -t is important since auto-detection is not always reliable
    mount_args="-t $filesystem $mount_args"
}

initial_cleanup()
{
    # Make sure all filesystems are OK, and there are no data left from previous tests
    log "initial_cleanup started\n"
    wait_target_up
    for fs_num in `seq 0 $filesystems_max`; do
        set_global_vars
        fs_check
        fs_mount
        for test_num in `seq 0 $target_tests_max`; do
            set_global_vars
            data_check
        done
        fs_umount
    done
    log "initial_cleanup finished\n"
}

#-------------------------
# main loop

let target_tests_max=${#TARGET_TESTS[@]}-1
let filesystems_max=${#FILESYSTEMS[@]}-1

cycle=0

log "\n\n"
log "==== Test started ($TARGET:${TARGET_TESTS[@]}:${FILESYSTEMS[@]}:$TEST_LOG:$TARGET_TEST_LOG) ====\n"
disk_info
initial_cleanup
while true; do
    for test_num in `seq 0 $target_tests_max`; do
        for fs_num in `seq 0 $filesystems_max`; do
            let cycle++

            wait_target_up

            fs_check

            fs_mount
            data_check
            fs_umount

            set_global_vars

            log "--- cycle $cycle ($target_test:$max_timeout:$partition:$filesystem:$mount_args) ---\n"

            fs_mount
            start_target_test

            let random_timeout=$RANDOM%$max_timeout
            sleep $random_timeout
            power_cycle
            # It is assumed that power_cycle is not immediate. So we have time to login
            # to the target inside wait_target_down() below
            wait_target_down
        done
    done
done

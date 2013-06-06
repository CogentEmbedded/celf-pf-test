
# Collect duration statistics on fsck, mount, and umount
# operations performed by pf-test.sh
#
# Usage: gawk -f pf-stat.awk test.log
#
# -- dmitry.semyonov@cogentembedded.com

BEGIN {
    min_btrfs_fsck_time = 999
    min_btrfsperf_fsck_time = 999
    min_f2fs_fsck_time = 999
    min_f2fsperf_fsck_time = 999
    min_ext4_fsck_time = 999
    min_ext4perf_fsck_time = 999

    min_btrfs_mount_time = 999
    min_btrfsperf_mount_time = 999
    min_f2fs_mount_time = 999
    min_f2fsperf_mount_time = 999
    min_ext4_mount_time = 999
    min_ext4perf_mount_time = 999

    min_btrfs_umount_time = 999
    min_btrfsperf_umount_time = 999
    min_f2fs_umount_time = 999
    min_f2fsperf_umount_time = 999
    min_ext4_umount_time = 999
    min_ext4perf_umount_time = 999
}

/fs_mount started/ { mount = 1; next }
/fs_umount started/ { umount = 1; next }
/fs_check started/ { fsck = 1; next }

/fs_mount mount -t btrfs -o/ { fstype = "btrfsperf"; next }
/fs_mount mount -t btrfs/ { fstype = "btrfs"; next }
/fs_mount mount -t f2fs -o/ { fstype = "f2fsperf"; next }
/fs_mount mount -t f2fs/ { fstype = "f2fs"; next }
/fs_mount mount -t ext4 -o/ { fstype = "ext4perf"; next }
/fs_mount mount -t ext4/ { fstype = "ext4"; next }

/^real\t[0-9]+m[0-9.]+s/ {
    # Skip failed operations
    if (fail == 1) {
        fsck = mount = umount = 0
        fail = 0
        next
    }

    split($2, t, "m")
    mins=t[1]
    split(t[2], tt, "s")
    secs=tt[1]
    time=mins*60+secs

    if (fsck == 1) {
        if (fstype == "btrfsperf") {
            if (time > max_btrfsperf_fsck_time)
                max_btrfsperf_fsck_time = time
            if (time < min_btrfsperf_fsck_time)
                min_btrfsperf_fsck_time = time

            total_btrfsperf_fsck_time += time
            total_btrfsperf_fsck_results++
            btrfsperf_fsck_time[total_btrfsperf_fsck_results] = time+0
        }
        else if (fstype == "f2fsperf") {
            if (time > max_f2fsperf_fsck_time)
                max_f2fsperf_fsck_time = time
            if (time < min_f2fsperf_fsck_time)
                min_f2fsperf_fsck_time = time

            total_f2fsperf_fsck_time += time
            total_f2fsperf_fsck_results++
            f2fsperf_fsck_time[total_f2fsperf_fsck_results] = time+0
        }
        else if (fstype == "ext4perf") {
            if (time > max_ext4perf_fsck_time)
                max_ext4perf_fsck_time = time
            if (time < min_ext4perf_fsck_time)
                min_ext4perf_fsck_time = time

            total_ext4perf_fsck_time += time
            total_ext4perf_fsck_results++
            ext4perf_fsck_time[total_ext4perf_fsck_results] = time+0
        }
        else if (fstype == "btrfs") {
            if (time > max_btrfs_fsck_time)
                max_btrfs_fsck_time = time
            if (time < min_btrfs_fsck_time)
                min_btrfs_fsck_time = time

            total_btrfs_fsck_time += time
            total_btrfs_fsck_results++
            btrfs_fsck_time[total_btrfs_fsck_results] = time+0
        }
        else if (fstype == "f2fs") {
            if (time > max_f2fs_fsck_time)
                max_f2fs_fsck_time = time
            if (time < min_f2fs_fsck_time)
                min_f2fs_fsck_time = time

            total_f2fs_fsck_time += time
            total_f2fs_fsck_results++
            f2fs_fsck_time[total_f2fs_fsck_results] = time+0
        }
        else if (fstype == "ext4") {
            if (time > max_ext4_fsck_time)
                max_ext4_fsck_time = time
            if (time < min_ext4_fsck_time)
                min_ext4_fsck_time = time

            total_ext4_fsck_time += time
            total_ext4_fsck_results++
            ext4_fsck_time[total_ext4_fsck_results] = time+0
        }
    }
    else if (mount == 1) {
        if (fstype == "btrfsperf") {
            if (time > max_btrfsperf_mount_time)
                max_btrfsperf_mount_time = time
            if (time < min_btrfsperf_mount_time)
                min_btrfsperf_mount_time = time

            total_btrfsperf_mount_time += time
            total_btrfsperf_mount_results++
            btrfsperf_mount_time[total_btrfsperf_mount_results] = time+0
        }
        else if (fstype == "f2fsperf") {
            if (time > max_f2fsperf_mount_time)
                max_f2fsperf_mount_time = time
            if (time < min_f2fsperf_mount_time)
                min_f2fsperf_mount_time = time

            total_f2fsperf_mount_time += time
            total_f2fsperf_mount_results++
            f2fsperf_mount_time[total_f2fsperf_mount_results] = time+0
        }
        else if (fstype == "ext4perf") {
            if (time > max_ext4perf_mount_time)
                max_ext4perf_mount_time = time
            if (time < min_ext4perf_mount_time)
                min_ext4perf_mount_time = time

            total_ext4perf_mount_time += time
            total_ext4perf_mount_results++
            ext4perf_mount_time[total_ext4perf_mount_results] = time+0
        }
        else if (fstype == "btrfs") {
            if (time > max_btrfs_mount_time)
                max_btrfs_mount_time = time
            if (time < min_btrfs_mount_time)
                min_btrfs_mount_time = time

            total_btrfs_mount_time += time
            total_btrfs_mount_results++
            btrfs_mount_time[total_btrfs_mount_results] = time+0
        }
        else if (fstype == "f2fs") {
            if (time > max_f2fs_mount_time)
                max_f2fs_mount_time = time
            if (time < min_f2fs_mount_time)
                min_f2fs_mount_time = time

            total_f2fs_mount_time += time
            total_f2fs_mount_results++
            f2fs_mount_time[total_f2fs_mount_results] = time+0
        }
        else if (fstype == "ext4") {
            if (time > max_ext4_mount_time)
                max_ext4_mount_time = time
            if (time < min_ext4_mount_time)
                min_ext4_mount_time = time

            total_ext4_mount_time += time
            total_ext4_mount_results++
            ext4_mount_time[total_ext4_mount_results] = time+0
        }
    }
    else if (umount == 1) {
        if (fstype == "btrfsperf") {
            if (time > max_btrfsperf_umount_time)
                max_btrfsperf_umount_time = time
            if (time < min_btrfsperf_umount_time)
                min_btrfsperf_umount_time = time

            total_btrfsperf_umount_time += time
            total_btrfsperf_umount_results++
            btrfsperf_umount_time[total_btrfsperf_umount_results] = time+0
        }
        else if (fstype == "f2fsperf") {
            if (time > max_f2fsperf_umount_time)
                max_f2fsperf_umount_time = time
            if (time < min_f2fsperf_umount_time)
                min_f2fsperf_umount_time = time

            total_f2fsperf_umount_time += time
            total_f2fsperf_umount_results++
            f2fsperf_umount_time[total_f2fsperf_umount_results] = time+0
        }
        else if (fstype == "ext4perf") {
            if (time > max_ext4perf_umount_time)
                max_ext4perf_umount_time = time
            if (time < min_ext4perf_umount_time)
                min_ext4perf_umount_time = time

            total_ext4perf_umount_time += time
            total_ext4perf_umount_results++
            ext4perf_umount_time[total_ext4perf_umount_results] = time+0
        }
        else if (fstype == "btrfs") {
            if (time > max_btrfs_umount_time)
                max_btrfs_umount_time = time
            if (time < min_btrfs_umount_time)
                min_btrfs_umount_time = time

            total_btrfs_umount_time += time
            total_btrfs_umount_results++
            btrfs_umount_time[total_btrfs_umount_results] = time+0
        }
        else if (fstype == "f2fs") {
            if (time > max_f2fs_umount_time)
                max_f2fs_umount_time = time
            if (time < min_f2fs_umount_time)
                min_f2fs_umount_time = time

            total_f2fs_umount_time += time
            total_f2fs_umount_results++
            f2fs_umount_time[total_f2fs_umount_results] = time+0
        }
        else if (fstype == "ext4") {
            if (time > max_ext4_umount_time)
                max_ext4_umount_time = time
            if (time < min_ext4_umount_time)
                min_ext4_umount_time = time

            total_ext4_umount_time += time
            total_ext4_umount_results++
            ext4_umount_time[total_ext4_umount_results] = time+0
        }
    }
    fsck = mount = umount = 0
    next
}

/Command exited with non-zero status/ {
    # it is expected for fsck to return 1 when it fixes minor issues
    if (fsck != 1 || $6 != 1)
      fail = 1
    next
}

/ ==== Test started / { fsck = mount = umount = 0; fail = 0; next }

END {
    asort(btrfs_fsck_time)
    asort(f2fs_fsck_time)
    asort(ext4_fsck_time)
    asort(btrfs_mount_time)
    asort(f2fs_mount_time)
    asort(ext4_mount_time)
    asort(btrfs_umount_time)
    asort(f2fs_umount_time)
    asort(ext4_umount_time)
    asort(btrfsperf_fsck_time)
    asort(f2fsperf_fsck_time)
    asort(ext4perf_fsck_time)
    asort(btrfsperf_mount_time)
    asort(f2fsperf_mount_time)
    asort(ext4perf_mount_time)
    asort(btrfsperf_umount_time)
    asort(f2fsperf_umount_time)
    asort(ext4perf_umount_time)

    if (total_btrfsperf_fsck_results > 0) {
        median_btrfsperf_fsck_time = btrfsperf_fsck_time[int(total_btrfsperf_fsck_results / 2) + 1]
        mean_btrfsperf_fsck_time = total_btrfsperf_fsck_time / total_btrfsperf_fsck_results
    }
    if (total_f2fsperf_fsck_results > 0) {
        median_f2fsperf_fsck_time = f2fsperf_fsck_time[int(total_f2fsperf_fsck_results / 2) + 1]
        mean_f2fsperf_fsck_time = total_f2fsperf_fsck_time / total_f2fsperf_fsck_results
    }
    if (total_ext4perf_fsck_results > 0) {
        median_ext4perf_fsck_time = ext4perf_fsck_time[int(total_ext4perf_fsck_results / 2) + 1]
        mean_ext4perf_fsck_time = total_ext4perf_fsck_time / total_ext4perf_fsck_results
    }


    if (total_btrfsperf_mount_results  > 0) {
        median_btrfsperf_mount_time = btrfsperf_mount_time[int(total_btrfsperf_mount_results / 2 + 1)]
        mean_btrfsperf_mount_time = total_btrfsperf_mount_time / total_btrfsperf_mount_results
    }
    if (total_f2fsperf_mount_results  > 0) {
        median_f2fsperf_mount_time = f2fsperf_mount_time[int(total_f2fsperf_mount_results / 2 + 1)]
        mean_f2fsperf_mount_time = total_f2fsperf_mount_time / total_f2fsperf_mount_results
    }
    if (total_ext4perf_mount_results  > 0) {
        median_ext4perf_mount_time = ext4perf_mount_time[int(total_ext4perf_mount_results / 2 + 1)]
        mean_ext4perf_mount_time = total_ext4perf_mount_time / total_ext4perf_mount_results
    }


    if (total_btrfsperf_umount_results  > 0) {
        median_btrfsperf_umount_time = btrfsperf_umount_time[int(total_btrfsperf_umount_results / 2 + 1)]
        mean_btrfsperf_umount_time = total_btrfsperf_umount_time / total_btrfsperf_umount_results
    }
    if (total_f2fsperf_umount_results  > 0) {
        median_f2fsperf_umount_time = f2fsperf_umount_time[int(total_f2fsperf_umount_results / 2 + 1)]
        mean_f2fsperf_umount_time = total_f2fsperf_umount_time / total_f2fsperf_umount_results
    }
    if (total_ext4perf_umount_results  > 0) {
        median_ext4perf_umount_time = ext4perf_umount_time[int(total_ext4perf_umount_results / 2 + 1)]
        mean_ext4perf_umount_time = total_ext4perf_umount_time / total_ext4perf_umount_results
    }

    if (total_btrfs_fsck_results > 0) {
        median_btrfs_fsck_time = btrfs_fsck_time[int(total_btrfs_fsck_results / 2) + 1]
        mean_btrfs_fsck_time = total_btrfs_fsck_time / total_btrfs_fsck_results
    }
    if (total_f2fs_fsck_results > 0) {
        median_f2fs_fsck_time = f2fs_fsck_time[int(total_f2fs_fsck_results / 2) + 1]
        mean_f2fs_fsck_time = total_f2fs_fsck_time / total_f2fs_fsck_results
    }
    if (total_ext4_fsck_results > 0) {
        median_ext4_fsck_time = ext4_fsck_time[int(total_ext4_fsck_results / 2) + 1]
        mean_ext4_fsck_time = total_ext4_fsck_time / total_ext4_fsck_results
    }


    if (total_btrfs_mount_results  > 0) {
        median_btrfs_mount_time = btrfs_mount_time[int(total_btrfs_mount_results / 2 + 1)]
        mean_btrfs_mount_time = total_btrfs_mount_time / total_btrfs_mount_results
    }
    if (total_f2fs_mount_results  > 0) {
        median_f2fs_mount_time = f2fs_mount_time[int(total_f2fs_mount_results / 2 + 1)]
        mean_f2fs_mount_time = total_f2fs_mount_time / total_f2fs_mount_results
    }
    if (total_ext4_mount_results  > 0) {
        median_ext4_mount_time = ext4_mount_time[int(total_ext4_mount_results / 2 + 1)]
        mean_ext4_mount_time = total_ext4_mount_time / total_ext4_mount_results
    }


    if (total_btrfs_umount_results  > 0) {
        median_btrfs_umount_time = btrfs_umount_time[int(total_btrfs_umount_results / 2 + 1)]
        mean_btrfs_umount_time = total_btrfs_umount_time / total_btrfs_umount_results
    }
    if (total_f2fs_umount_results  > 0) {
        median_f2fs_umount_time = f2fs_umount_time[int(total_f2fs_umount_results / 2 + 1)]
        mean_f2fs_umount_time = total_f2fs_umount_time / total_f2fs_umount_results
    }
    if (total_ext4_umount_results  > 0) {
        median_ext4_umount_time = ext4_umount_time[int(total_ext4_umount_results / 2 + 1)]
        mean_ext4_umount_time = total_ext4_umount_time / total_ext4_umount_results
    }

    print  "                     :    min |    max |   mean | median | count"
    printf "btrfs         fsck   : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_btrfs_fsck_time, max_btrfs_fsck_time, mean_btrfs_fsck_time, median_btrfs_fsck_time, total_btrfs_fsck_results
    printf "f2fs         fsck   : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_f2fs_fsck_time, max_f2fs_fsck_time, mean_f2fs_fsck_time, median_f2fs_fsck_time, total_f2fs_fsck_results
    printf "ext4         fsck   : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_ext4_fsck_time, max_ext4_fsck_time, mean_ext4_fsck_time, median_ext4_fsck_time, total_ext4_fsck_results
    print ""
    printf "btrfs         mount  : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_btrfs_mount_time, max_btrfs_mount_time, mean_btrfs_mount_time, median_btrfs_mount_time, total_btrfs_mount_results
    printf "f2fs         mount  : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_f2fs_mount_time, max_f2fs_mount_time, mean_f2fs_mount_time, median_f2fs_mount_time, total_f2fs_mount_results
    printf "ext4         mount  : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_ext4_mount_time, max_ext4_mount_time, mean_ext4_mount_time, median_ext4_mount_time, total_ext4_mount_results
    print ""
    printf "btrfs         umount : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_btrfs_umount_time, max_btrfs_umount_time, mean_btrfs_umount_time, median_btrfs_umount_time, total_btrfs_umount_results
    printf "f2fs         umount : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_f2fs_umount_time, max_f2fs_umount_time, mean_f2fs_umount_time, median_f2fs_umount_time, total_f2fs_umount_results
    printf "ext4         umount : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_ext4_umount_time, max_ext4_umount_time, mean_ext4_umount_time, median_ext4_umount_time, total_ext4_umount_results

    printf "btrfsperf         fsck   : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_btrfsperf_fsck_time, max_btrfsperf_fsck_time, mean_btrfsperf_fsck_time, median_btrfsperf_fsck_time, total_btrfsperf_fsck_results
    printf "f2fsperf         fsck   : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_f2fsperf_fsck_time, max_f2fsperf_fsck_time, mean_f2fsperf_fsck_time, median_f2fsperf_fsck_time, total_f2fsperf_fsck_results
    printf "ext4perf         fsck   : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_ext4perf_fsck_time, max_ext4perf_fsck_time, mean_ext4perf_fsck_time, median_ext4perf_fsck_time, total_ext4perf_fsck_results
    print ""
    printf "btrfsperf         mount  : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_btrfsperf_mount_time, max_btrfsperf_mount_time, mean_btrfsperf_mount_time, median_btrfsperf_mount_time, total_btrfsperf_mount_results
    printf "f2fsperf         mount  : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_f2fsperf_mount_time, max_f2fsperf_mount_time, mean_f2fsperf_mount_time, median_f2fsperf_mount_time, total_f2fsperf_mount_results
    printf "ext4perf         mount  : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_ext4perf_mount_time, max_ext4perf_mount_time, mean_ext4perf_mount_time, median_ext4perf_mount_time, total_ext4perf_mount_results
    print ""
    printf "btrfsperf         umount : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_btrfsperf_umount_time, max_btrfsperf_umount_time, mean_btrfsperf_umount_time, median_btrfsperf_umount_time, total_btrfsperf_umount_results
    printf "f2fsperf         umount : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_f2fsperf_umount_time, max_f2fsperf_umount_time, mean_f2fsperf_umount_time, median_f2fsperf_umount_time, total_f2fsperf_umount_results
    printf "ext4perf         umount : %6.2f | %6.2f | %6.2f | %6.2f | %d\n", min_ext4perf_umount_time, max_ext4perf_umount_time, mean_ext4perf_umount_time, median_ext4perf_umount_time, total_ext4perf_umount_results
}

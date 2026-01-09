#!/bin/sh

PATH="/bin:/sbin:/usr/bin:/usr/sbin:${PATH}"
export PATH

ARC_PCT="50"
ARC_BYTES=$(grep '^MemTotal' /proc/meminfo | awk -v pct=${ARC_PCT} '{printf "%d", $2 * 1024 * (pct / 100.0)}')
echo ${ARC_BYTES} > /sys/module/zfs/parameters/zfs_arc_max

ARC_PCT="40"
ARC_BYTES=$(grep '^MemTotal' /proc/meminfo | awk -v pct=${ARC_PCT} '{printf "%d", $2 * 1024 * (pct / 100.0)}')
echo ${ARC_BYTES} > /sys/module/zfs/parameters/zfs_arc_min


SYS_FREE_BYTES=$((16*1024*1024*1024))
echo ${SYS_FREE_BYTES} > /sys/module/zfs/parameters/zfs_arc_sys_free
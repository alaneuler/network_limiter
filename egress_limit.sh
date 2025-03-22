#!/usr/bin/bash
set -e

if [ $# -lt 2 ]; then
    echo "Usage: limit.sh <pid | command> <speed> [interface]"
    exit 1
fi

poc=$1
speed=$2
interface="${3:-eth0}"

echo "Limiting \"$poc\" to $speed on interface $interface"

if [ ! -d "/sys/fs/cgroup/net_cls" ]; then
    echo "net_cls subsystem not found, load it..."
    mkdir /sys/fs/cgroup/net_cls
    mount -t cgroup -onet_cls net_cls /sys/fs/cgroup/net_cls
fi

cgroup="limited_bw_$RANDOM"
major=$(printf '%04x' $((1 + $RANDOM % 65535)))
minor=$(printf '%04x' $((1 + $RANDOM % 65535)))
echo "Creating net_cls cgroup $cgroup with class ID 0x$major:$minor"
cgcreate -g net_cls:$cgroup
cgset -r "net_cls.classid=0x$major$minor" $cgroup

echo "Configuring tc..."
tc qdisc add dev $interface root handle $major: htb
tc class add dev $interface parent $major: classid $major:$minor htb rate $speed
tc filter add dev $interface parent $major: handle 1: cgroup

if [ "$poc" -eq "$poc" ] 2>/dev/null; then
    echo "Assume pid, limit existing process"
    cgclassify -g net_cls:$cgroup $poc
else
    echo "Assume command, execute the command"
    cgexec -g net_cls:$cgroup $poc
fi

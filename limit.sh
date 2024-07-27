#!/usr/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: limit.sh <pid_or_command> <speed> [interface]"
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
minor=$(printf '%04x' $((1 + $RANDOM % 65535)))
echo "Creating net_cls cgroup $cgroup with handle 10:$minor"
cgcreate -g net_cls:$cgroup
cgset -r "net_cls.classid=0x10$minor" $cgroup

echo "Configuring tc..."
tc qdisc add dev $interface root handle 10: htb 2>/dev/null
tc class add dev $interface parent 10: classid "10:$minor" htb rate $speed
tc filter add dev $interface parent 10: protocol ip prio 1 handle 1: cgroup

if [ "$poc" -eq "$poc" ] 2>/dev/null; then
    echo "Assume pid, limit existing process"
    cgclassify -g net_cls:$cgroup $poc
else
    echo "Assum command, execute the command"
    cgexec -g net_cls:$cgroup $poc
fi

# Linux Network Limiter
Limit a Linux progress's egress network bandwidth.

## Prerequisites
```bash
sudo apt install cgroup-tools
```

## Usage
```bash
# Execute a new command with network limiting
sudo bash egress_limit.sh "iperf -s" 10mbit
# Defaults to eth0, use different interface
sudo bash egress_limit.sh "iperf -s --bind-dev eth1" 10mbit eth1

# Limit an existing process
sudo bash egress_limit.sh ${pid} 10mbit
```

Remove the process limit:
```bash
sudo cgclassify -g net_cls:/ ${pid}
```

Remove the limit on interface:
```bash
sudo tc qdisc del dev eth0 root
```

# Linux Network Limiter
Limit egress network bandwidth.

## Prerequisites
```bash
sudo apt install cgroup-tools
```

## Usage
```bash
# Execute a new command with network limiting
sudo bash limit.sh "iperf -s" 10mbit
# Defaults to eth0, specify interface
sudo bash limit.sh "iperf -s" 10mbit eth1

# Limit an existing process
sudo bash limit.sh ${pid} 10mbit
```

Remove the limit:
```bash
sudo cgclassify -g net_cls:/ ${pid}
```

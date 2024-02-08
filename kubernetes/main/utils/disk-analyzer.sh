#!/usr/bin/env bash

#!/bin/bash

# Define an array of IP addresses
declare -a ips=("10.0.1.7" "10.0.1.8" "10.0.1.9" "10.0.1.149")

# Loop through each IP and execute the commands
for ip in "${ips[@]}"; do
    echo "Running commands for IP: $ip"
    talosctl -n "$ip" disks
    talosctl -n "$ip" ls /dev/disk/by-id -l
done

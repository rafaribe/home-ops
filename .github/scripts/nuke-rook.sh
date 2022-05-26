#!/bin/bash

rm -rf /var/lib/rook
sgdisk --zap-all /dev/sda 
dd if=/dev/zero of="/dev/sda" bs=1M count=100 oflag=direct,dsync
ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %
rm -rf /dev/mapper/ceph-*
rm -rf /dev/ceph-*
partprobe /dev/sda 
ls -l /dev/mapper 
wipefs -fa /dev/sda
lsblk -f

rm -rf /var/lib/rook
sgdisk --zap-all /dev/sdb
dd if=/dev/zero of="/dev/sdb" bs=1M count=100 oflag=direct,dsync
ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %
rm -rf /dev/mapper/ceph-*
rm -rf /dev/ceph-*
partprobe /dev/sdb 
ls -l /dev/mapper 
lsblk -f
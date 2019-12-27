#!/bin/ash

#TODO# One day, the rootfs_files() should allow DEST=/path/in/rootfs

touch /etc/mdev.conf

mv /init.ash /init
mv /inittab /etc

mkdir -p       /usr/lib/twin
mv /ide.twinrc /usr/lib/twin/system.twinrc
mkdir -p       /usr/share/udhcpc/
mv /udhcpc.ash /usr/share/udhcpc/default.script 

# rm "$0"

#!/bin/ash

#TODO# One day, the rootfs_files() should allow DEST=/path/in/rootfs

mv /init.ash /init
mv /inittab /etc
mv /ide.twinrc /usr/lib/twin/system.twinrc
mv /udhcpc.ash /usr/share/udhcpc/default.script 
touch /etc/mdev.conf

# rm "$0"

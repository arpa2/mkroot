#!/bin/bash
#
# fixup script to install busybox' links

#TODO# bin/busybox --install -s

bin/busybox --list | \
while read CMD
do
	ln -s busybox "bin/$CMD"
done

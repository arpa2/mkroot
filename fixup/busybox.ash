#!/bin/busybox ash
#
# fixup script to install busybox' links

#TODO# bin/busybox --install -s

/bin/busybox --list | \
while read CMD
do
	if [ ! -h "/bin/$CMD" ]
	then
		/bin/busybox ln -s busybox "/bin/$CMD"
	fi
done

#!/bin/sh

#Create all the symlinks to /bin/busybox
#DONE# /bin/busybox --install -s

#Index module dependencies
#DONE# depmod

#Mount things needed by this script
mkdir -p /proc /sys /tmp /dev
mount -t proc     proc   /proc
mount -t sysfs    sysfs  /sys
mount -t tmpfs    tmpfs  /tmp
mount -t devtmpfs udev   /dev
mkdir -p                 /dev/pts
mount -t devpts   devpts /dev/pts

#Preparing for DropBear
mkdir -p /etc/dropbear /var/log

echo Staring normal RS-232/485 serial ports
insmod /lib/modules/4.19.0-5-686/kernel/drivers/input/serio/serport.ko

echo Starting mouse support, assuming PS/2
insmod /lib/modules/4.19.0-5-686/kernel/drivers/input/mouse/psmouse.ko
mkdir -p /var/run                  

#Create device nodes
# mknod /dev/null c 1 3
# mknod /dev/tty c 5 0
# mdev -s

#Disable kernel messages from popping onto the screen
echo 0 > /proc/sys/kernel/printk

#Setup the network
echo Setup the network
ifconfig lo up
modprobe 8139too
ifconfig eth0 up
udhcpc -i eth0

#Clear the screen
# clear

echo 'Trying to continue as BusyBox init'
exec /sbin/init

#This will only be run if the exec above failed
echo "Failed to run init, dropping to a shell"
exec sh

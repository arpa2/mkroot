#!/bin/ash
#
# Quit immediately if we are on the console,
# and leave it to init to avoid any trouble.
#
# As soon as tty1 starts, things will be good
# enough for TWIN, who is sensitive to this.


if [ `tty` != "/dev/console" ]
then
	exec /usr/bin/twin_server
fi

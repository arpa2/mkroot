#!/bin/ash
#
# Remove development files from the rootfs.
#
# This is used to keep a file system small, under the assumption
# that it will not be used for development.  In that case, there
# is no need for .a libraries or for any include files.
#
# From: Rick van Rein <rick@openfortress.nl>


find /lib* /usr/lib* /usr/local/lib* /usr/share/lib* \
	-name \*.a \
	-exec rm {} \;

rm -rf /usr/include /usr/local/include


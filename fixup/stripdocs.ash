#!/bin/ash
#
# Remove documentation files from the rootfs.
#
# The default list that is erased may be expanded with time,
# but is supposed to include all files that are not essential
# to the running of programs inside a container.  This can be
# useful to strip down a rootfs to its bare minimum size.
#
# From: Rick van Rein <rick@openfortress.nl>


rm -rf /usr/share/doc /usr/share/man /usr/share/info

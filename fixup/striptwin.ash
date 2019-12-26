#!/bin/ash
#
# Remove documentation files from the TWIN textual user interfaec.
#
# Mostly build information can go:
#  - include files (.h)
#  - documentation file shares
#  - linker objects (.la)
#  - static link libraries (.a)
#
# From: Rick van Rein <rick@openfortress.nl>


rm -rf /usr/include

rm -rf /usr/share/twin

find /usr/lib/ -name \*.a  -exec rm {} \;
find /usr/lib/ -name \*.la -exec rm {} \;


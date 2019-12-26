#!/bin/bash
#
# Given a current directory with a OCI_bundle.index file, collect the
# various components that make this bundle fit for OpenContainers.
#
# Called as "<this_script>".
#
# From: Rick van Rein <rick@openfortress.nl>


if [ ! -d "rootfs" ]
then
	echo >&2 "Error: No directory $(pwd)/rootfs"
	exit 1
fi

if [ ! -r "config.json" ]
then
	echo >&2 "Error: No bundle configuration file $(pwd)/config.json"
	exit 1
fi


echo 'CMake properly delivered rootfs/ and config.json'
exit 0

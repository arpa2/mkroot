#!/bin/bash
#
# Given a current directory with a PXE.index file, produce the file
# initrd.cpiogz to be passed into the kernel.  Additional PXE scripts
# may be produced as part of the rootfs_runkind() statement, but they
# are optional extras as far as this script is concerned.
#
# Called as "<this_script>".
#
# From: Rick van Rein <rick@openfortress.nl>


if [ ! -d "rootfs" ]
then
	echo >&2 "Error: No directory $(pwd)/rootfs"
	exit 1
fi

if [ -r "vmlinuz" ]
then
	#TODO# echo >&2 "Error: No kernel $(pwd)/vmlinuz"
	#TODO# exit 1
	echo >&2 "TODO: The kernel should not end up under rootfs"
fi


#TODO# Might check "vmlinuz" version against rootfs/lib/modules/*


# Produce the CPIO archive with initrd.gz
#TODO# Capture any errors... but how?
#
( cd rootfs ; find . | cpio --quiet -H newc -o | gzip ) > "initrd.cpiogz"


# Report success
#
exit 0

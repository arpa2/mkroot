# Windows "mkhere" build environment.
#
# This produces Windows binaries using the "mkhere" environment.
#
# From: Rick van Rein <rick@openfortress.nl>


# First we define the rootfs name, used as a reference for building
#
add_rootfs(windows-mkhere)


# Binary packages that are extracted from the underlying OS
#
rootfs_ospackages(
	busybox
	bash
	gawk sed
	bison flex
	git pkg-config
	cmake autoconf automake libtool
	gdbserver gdb
	wine
)

# Source packages built in the build OS and then exported
#
rootfs_packages(
	pacman
)

# Directories that should be created in the rootfs
#
rootfs_directories(
	/etc
	/dev /dev/pts
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/tmp
	/proc /sys
	/var/log
)

# Files from the build OS to be copied into the rootfs
#
rootfs_files(
	/etc/passwd
	/etc/shadow
	/etc/group
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
	# The "mkhere" environment
	/mkhere/* /mkhere/lib/*
	# Lacking a path, README.MD ends up in the root directory
	README.MD
)

# Include terminal information files
#
rootfs_terminfo(
	# ansi
	# linux
	# xterm*
	# vt* 
)

# Include commands from the OS
#
rootfs_oscommands(
)

# Include libraries from the OS
#
rootfs_oslibraries(
	nss_files
)

# Include kernel modules for access to serial ports
#
rootfs_kernel(
	# #TODO# Some day, dependencies should be added automatically
	# mii 8139cp 8139too
	# psmouse
	# serport serio_raw
	# parport_serial parport_pc parport 
	# pl2303 ftdi_sio 
	# usbserial usb-common usbcore 
	# xhci-hcd uhci-hcd ehci-pci ehci-hcd whci-hcd ohci-hcd vhci-hcd
)

# Fixup scripts are run to correct the filled rootfs
#
rootfs_fixups(
	busybox.ash
	# striptwin.ash
	# stripdocs.ash
	# myfixup.ash
)

# Construct binaries that to be used for the desired runkind
#
rootfs_runkind(PXE
	#TODO#o ptional pxelinux.cfg scripts and such
)
#
#TODO# rootfs_runkind(OCI_bundle
#TODO# 	config.json
#TODO# )


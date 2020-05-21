# InternetWide Architecture Component: KIP and HAAN Service.
#
# The constructs a root file system for a KIP Service daemon,
# along with HAAN Service, based on mkhere building and packaging.
#
# From: Rick van Rein <rick@openfortress.nl>


add_rootfs(kiphaan)

rootfs_ospackages(
	busybox # bash
	libkrb5-3 libk5crypto3
	libsasl2-2
	libunbound8
	freediameter freediameter-extensions freediameterd
	libc-bin
)

rootfs_packages(
	arpa2cm
	quickder
	kip
	# arpa2shell	VERSION=1.2.3
	# twin		VERSION=v0.8.1
)

rootfs_directories(
	/etc
	/dev
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/tmp
	/proc /sys
	/var/log
)

rootfs_files(
	# /etc/passwd
	# /etc/shadow
	# /etc/group
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
	README.MD
	etc/inittab
	#WONTWORK# etc/profile
)

rootfs_fixups(
	busybox.ash
	stripdev.ash
	ldconfig.ash
)

rootfs_downloads(
	# "http://internetwide.org/index.html"
	# "http://internetwide.org/tag/identity.html"
)

rootfs_runkind(OCI_bundle
	config.json
	net4kip.sh
)

# rootfs_kernel(
	# ftdi_sio
	# loop
# )



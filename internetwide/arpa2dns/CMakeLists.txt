# InternetWide Architecture Component: ARPA2DNS
#
# The constructs a root file system for an arpa2dns service,
# based on mkhere building and packaging.
#
# From: Rick van Rein <rick@openfortress.nl>


add_rootfs(arpa2dns)

rootfs_ospackages(
	busybox # bash
	python3-minimal
	libpython3.7-minimal
	libpython3-stdlib
	python3.7-minimal
	libpython3.7-stdlib
	python3-six
	knot knot-dnsutils
)

rootfs_packages(
	arpa2shell	VERSION=1.2.3
	twin		VERSION=v0.8.1
)

rootfs_directories(
	/etc
	/dev
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/tmp
	/proc /sys
	/var/log
	/run/knot /var/lib/knot
)

rootfs_files(
	# /etc/passwd
	# /etc/shadow
	# /etc/group
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
	README.MD
)

rootfs_fixups(
	busybox.ash
	stripdocs.ash
)

rootfs_downloads(
	# "http://internetwide.org/index.html"
	# "http://internetwide.org/tag/identity.html"
)

rootfs_runkind(OCI_bundle
	config.json
)

# rootfs_kernel(
	# ftdi_sio
	# loop
# )



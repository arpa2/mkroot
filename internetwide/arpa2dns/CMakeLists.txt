# InternetWide Architecture Component: ARPA2DNS
#
# The constructs a root file system for an arpa2dns service,
# based on mkhere building and packaging.
#
# From: Rick van Rein <rick@openfortress.nl>


add_component(arpa2dns)

component_ospackages(
	busybox # bash
	python3.7-minimal
	libpython3.7-stdlib
	# python3.7-six python3.7-enum34
	knot knot-dnsutils
)

component_packages(
	twin
)

component_directories(
	/etc
	/dev
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/tmp
	/proc /sys
	/var/log
	/run/knot /var/lib/knot
)

component_files(
	# /etc/passwd
	# /etc/shadow
	# /etc/group
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
	README.MD
)

component_fixups(
	busybox
	stripdocs
)

component_downloads(
	# "http://internetwide.org/index.html"
	# "http://internetwide.org/tag/identity.html"
)

component_runkind(OCI_bundle
	config.json
)


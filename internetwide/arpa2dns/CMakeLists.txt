# InternetWide Architecture Component: ARPA2DNS
#
# The constructs a root file system for an arpa2dns service,
# based on mkhere building and packaging.
#
# From: Rick van Rein <rick@openfortress.nl>


add_component(arpa2dns)

component_ospackages(
	bash
	python3-minimal
	knot knot-dnsutils
)

#TODO# component_packages(
	#TODO# knot
#TODO# )

component_directories(
	/etc
	/dev
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/proc /sys
)

component_files(
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
)

component_fixups(
	# testfix
	# otherfix
)

component_downloads(
	# "http://internetwide.org/index.html"
	# "http://internetwide.org/tag/identity.html"
)

component_contribs(OCI_bundle
	config.json
)


# InternetWide Architecture Component: ARPA2DNS
#
# The constructs a root file system for an arpa2dns service,
# based on mkhere building and packaging.
#
# From: Rick van Rein <rick@openfortress.nl>


add_component(arpa2dns)

component_packages(
	knot
	#python3
)

component_contribs(funny_bundle #TODO# OCI_bundle
	config.json)

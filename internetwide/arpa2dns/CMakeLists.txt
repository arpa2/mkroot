# InternetWide Architecture Component: ARPA2DNS
#
# The constructs a root file system for an arpa2dns service,
# based on mkhere building and packaging.
#
# From: Rick van Rein <rick@openfortress.nl>


add_component(arpa2dns)

#TODO# component_packages(
	#TODO# knot
#TODO# )

component_ospackages(
	python3.7
)

component_contribs(OCI_bundle
	config.json
)


# InternetWide Architecture Component: ARPA2DNS
#
# The constructs a root file system for an arpa2dns service,
# based on mkhere building and packaging.
#
# From: Rick van Rein <rick@openfortress.nl>


add_component(arpa2dns)

component_ospackages(
	python3.7 python3
	knot knot-dnsutils
)

#TODO# component_packages(
	#TODO# knot
#TODO# )

component_fixups(
	testfix
	otherfix
)

component_downloads(
	"http://internetwide.org/index.html"
	"http://internetwide.org/tag/identity.html"
)

component_contribs(OCI_bundle
	config.json
)


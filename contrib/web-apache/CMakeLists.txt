# InternetWide Contribution: Web server Apache
#
# From: Rick van Rein <rick@openfortress.nl>


add_rootfs(web_apache)

rootfs_ospackages(
	busybox
	apache2
)

rootfs_packages(
	twin	VERSION=v0.8.1
	#arpa2id modules/extensions...
)

rootfs_directories(
	/etc
	/dev
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/tmp
	/proc /sys
	/var/log
	/var/www /home
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

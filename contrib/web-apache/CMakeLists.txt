# InternetWide Contribution: Web server Apache
#
# From: Rick van Rein <rick@openfortress.nl>


add_rootfs(web_apache)

rootfs_ospackages(
	busybox
	bash
	httpie
	apache2
	apache2-bin
	apache2-data
	apache2-utils
	zlib1g
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
	/var/www/html /home
)

#TODO# Change port 80 to 8000 (ports.conf and 000-default.conf)

#TODO# mknod /dev/urandom c 1 9

rootfs_files(
	/etc/passwd
	/etc/shadow
	/etc/group
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
	/etc/mime.types
        README.MD
	/var/www/html/index.html
	/etc/apache2/mods-enabled/*
	/usr/lib/*/libnss_files.so* /lib/*/libnss_files*.so*
	/usr/lib/*/libgcc_s.so*     /lib/*/libgcc_s*.so*
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

# Bootstrapping "mkhere" as a rootfs under a build OS of choice
#
# These rootfs have a "mkhere" directory in their roots, but are
# otherwise built upon a specific guest OS.  The rootfs systems
# built with a symbolic link to such a "mkhere" will follow the
# choice of the guest OS.
#
# From: Rick van Rein <rick@openfortress.nl>


option(BOOTSTRAP_DEBIAN_MKHERE "Bootstrap via \"mkhere\" on Debian, Ubuntu, Tanglu or Kali" OFF)
if(BOOTSTRAP_DEBIAN_MKHERE)
	add_subdirectory(debian)
endif()

option(BOOTSTRAP_WINDOWS_MKHERE "Bootstrap via \"mkhere\" on Windows" OFF)
if(BOOTSTRAP_WINDOWS_MKHERE)
	add_subdirectory(windows)
endif()


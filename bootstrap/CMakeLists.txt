# Bootstrapping "mkhere" as a rootfs under a build OS of choice
#
# These rootfs have a "mkhere" directory in their roots, but are
# otherwise built upon a specific guest OS.  The rootfs systems
# built with a symbolic link to such a "mkhere" will follow the
# choice of the guest OS.
#
# From: Rick van Rein <rick@openfortress.nl>


# Collect menu options for "mkhere" linkage
#
set(BOOTSTRAP_MKHERE_MENU_STRINGS "${BOOTSTRAP_MKHERE_MENU_DEFAULT}")


# Debian bootstrapping (for a selected suite)
#
option(BOOTSTRAP_DEBIAN_MKHERE "Bootstrap via \"mkhere\" on Debian, Ubuntu, Tanglu or Kali" OFF)
if(BOOTSTRAP_DEBIAN_MKHERE)
	add_subdirectory(debian)
	if(DEFINED DEBIAN_ROOTFS)
		list(APPEND
			BOOTSTRAP_MKHERE_MENU_STRINGS
			"${DEBIAN_ROOTFS}/mkhere")
	endif()
endif()


# Windows bootstrapping
#
option(BOOTSTRAP_WINDOWS_MKHERE "Bootstrap via \"mkhere\" on Windows" OFF)
if(BOOTSTRAP_WINDOWS_MKHERE)
	add_subdirectory(windows)
	if (DEFINED WINDOWS_ROOTFS)
		list(APPEND
			BOOTSTRAP_MKHERE_MENU_STRINGS
			"${WINDOWS_ROOTFS}/mkhere")
	endif()
endif()


# Set a bootstrapping menu that provides an alternative to "mkhere" symlinks
#
if(NOT DEFINED BOOTSTRAP_MKHERE_MENU)
	set(BOOTSTRAP_MKHERE_MENU
		"${BOOTSTRAP_MKHERE_MENU_DEFAULT}"
		CACHE STRING
		"How to bootstrap the \"mkhere\" facility for \"mkroot\"")
endif()
#
message(STATUS "Bootstrap menu: ${BOOTSTRAP_MKHERE_MENU_STRINGS}")
set_property(CACHE
	BOOTSTRAP_MKHERE_MENU
	PROPERTY STRINGS
	${BOOTSTRAP_MKHERE_MENU_STRINGS})


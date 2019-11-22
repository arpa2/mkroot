# InternetWide Architecture Component Builds
#
# This is a collection of components that can run the
# InternetWide Architecture, based on the ARPA2 projects
# that implement the various missing links and tools.
#
# See README.MD for details, including how to build.
#
# From: Rick van Rein <rick@openfortress.nl>


cmake_minimum_required(VERSION 3.13)


#
# Require a `mkhere` link.  Scan for mkhere/lib/stdlib to exist.
#
if(NOT DEFINED BUILDROOT_MKHERE)
	find_file(
		BUILDROOT_MKHERE_STDLIB
		stdlib
		PATHS ${CMAKE_CURRENT_BINARY_DIR}/mkhere/lib
		NO_DEFAULT_PATH)
	if("${BUILDROOT_MKHERE_STDLIB}" STREQUAL "BUILDROOT_MKHERE_STDLIB-NOTFOUND")
		message(FATAL_ERROR
			"Please create a \"mkhere\" symlink to a buildroot/mkhere tree")
	endif()
	#TODO# Resolve symlink (note that file(READ_SYMLINK...) is 3.14 only)
	#TODO# Traversal to parent directories with "/.." is ignored?!?
	get_filename_component(
		BUILDROOT_MKHERE
		"${BUILDROOT_MKHERE_STDLIB}/.."
		DIRECTORY
		CACHE)
	get_filename_component(
		BUILDROOT
		"${BUILDROOT_MKHERE}/.."
		DIRECTORY
		CACHE)
	message(STATUS
		"Setting up BUILDROOT_MKHERE directory ${BUILDROOT_MKHERE}")
else()
	message(STATUS
		"Reusing BUILDROOT_MKHERE directory ${BUILDROOT_MKHERE}")
endif()


#
# Support setting a component package list.
#
function(component_packages)
	foreach(PKG IN LISTS ARGV)
		if(NOT ${PKG}_VARIANT)
			set(${PKG}_VARIANT
				CACHE STRING "Variant of package ${PKG}")
			execute_process(
				COMMAND "$BUILDROOT_MKHERE/${PKG}.sh" variants
				RESULT_VARIABLE _EXIT
				OUTPUT_VARIABLE ${PKG}_VARIANTS)
			if(NOT _EXIT EQUAL 0)
				set (${PKG}_VARIANTS red white blue)
				message(WARNING #TODO# FATAL_ERROR
					"Failed to find variants for component ${CURRENT_COMPONENT} package ${PKG}")
			endif()
			set_property(CACHE
				${PKG}_VARIANT
				PROPERTY STRINGS
				${${PKG}_VARIANTS})
		endif()
		if(NOT DEFINED ${PKG}_FLAVOUR)
			set(${PKG}_FLAVOUR
				CACHE STRING "Flavour of package ${PKG}")
			execute_process(
				COMMAND "$BUILDROOT_MKHERE/${PKG}.sh" flavours
				RESULT_VARIABLE _EXIT
				OUTPUT_VARIABLE ${PKG}_FLAVOURS)
			if(NOT _EXIT EQUAL 0)
				set (${PKG}_FLAVOURS tangy sweet bitter umami)
				message(WARNING #TODO# FATAL_ERROR
					"Failed to find flavours for component ${CURRENT_COMPONENT} package ${PKG}")
			endif()
			set_property(CACHE
				${PKG}_FLAVOUR
				PROPERTY STRINGS
				${${PKG}_FLAVOURS})
		endif()
	endforeach()
endfunction(component_packages)


#
#TODO# Support setting a component OS package list.
#

#
#TODO# Support setting a component file list.
#

#
#TODO# Support setting a component kernel module list???
#

#
#TODO# Support adding contributed files per kind of contrib.
#


#
#
# Support including a subdirectory with a component.
macro(add_component _COMPONAME)
	set(CURRENT_COMPONENT ${_COMPONAME})
	add_subdirectory (${_COMPONAME})
	#TODO# Support component targets rootfs/* and contrib/$KIND/* and all.
	#TODO# Support an ALL target for all the components added.
endmacro()


#
#TODO# Include a subdirectory per component.
#
add_component(arpa2dns)

#
#TODO# Support configurable variants and flavours for each package.
#

#
#TODO# Support installs and uninstalls?
#

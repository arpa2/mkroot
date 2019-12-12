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

set(DEFAULT_RUNKIND "OCI_bundle")

set(PACKAGES_GENERATED "" CACHE INTERNAL "Packages generated so far")


#
# Require a `mkhere` link.  Scan for mkhere/lib/stdlib to exist.
#
if(NOT DEFINED BUILDROOT_MKHERE)
	if (${CMAKE_VERSION} VERSION_LESS "3.14.0")
		# Older CMAKE have no builtin for reading symbolic links
		find_file(
			BUILDROOT_MKHERE_STDLIB
			stdlib
			PATHS ${CMAKE_CURRENT_BINARY_DIR}/mkhere/lib
			NO_DEFAULT_PATH)
		if("${BUILDROOT_MKHERE_STDLIB}" STREQUAL "BUILDROOT_MKHERE_STDLIB-NOTFOUND")
			message(FATAL_ERROR
				"Please create a \"mkhere\" symlink to a buildroot/mkhere tree or define \$\{BUILDROOT_MKHERE\}")
		endif()
		message(STATUS
			"Found stdlib script file in ${BUILDROOT_MKHERE_STDLIB}")
		get_filename_component(
			BUILDROOT_MKHERE_LIB
			${BUILDROOT_MKHERE_STDLIB}
			DIRECTORY)
		get_filename_component(
			BUILDROOT_MKHERE
			"${BUILDROOT_MKHERE_LIB}"
			DIRECTORY
			CACHE)
		unset(BUILDROOT_MKHERE_STDLIB
			CACHE)
		# get_filename_component(
			# BUILDROOT
			# "${BUILDROOT_MKHERE}"
			# DIRECTORY
			# CACHE)
		# message(STATUS
			# "Found build root directory in ${BUILDROOT}")
	else()
		# 3.14+ can resolve symlink (note that file(READ_SYMLINK...)
		# Note: Fatal if the link is not found, or if not a link...
		file(READ_SYMLINK
			"mkhere"
			BUILDROOT_MKHERE)
	endif()
	message(STATUS
		"Configured BUILDROOT_MKHERE directory ${BUILDROOT_MKHERE}")
else()
	message(STATUS
		"Using BUILDROOT_MKHERE directory ${BUILDROOT_MKHERE}")
endif()


#
# Allow the choice of the kind of runtime environment.
# (This function is called automatically for each component.)
#
function(component__runkinds)
	if(NOT ${CURRENT_COMPONENT}_RUNKIND)
		set(${CURRENT_COMPONENT}_RUNKIND "${DEFAULT_RUNKIND}"
			CACHE STRING "Kind of runtime for component ${CURRENT_COMPONENT}")
	endif()
	list(REMOVE_DUPLICATES CURRENT_RUNKINDS)
	list(LENGTH CURRENT_RUNKINDS _LEN)
	list(FIND CURRENT_RUNKINDS "${DEFAULT_RUNKIND}" _IDX)
	if(${_LEN} EQUAL 0)
		#FIX# Avoid crash of ccmake on empty options list (!)
		#OLD# set(CURRENT_RUNKINDS "${DEFAULT_RUNKIND}")
		#DOUBLE# component_contribs ("${DEFAULT_RUNKIND}")
	elseif(${_IDX} EQUAL -1)
		message(WARNING
			"No contributions for runtime kind ${DEFAULT_RUNKIND} in component ${CURRENT_COMPONENT}")
	endif()
	set_property(CACHE
		${CURRENT_COMPONENT}_RUNKIND
		PROPERTY STRINGS
		"${DEFAULT_RUNKIND}" ${CURRENT_RUNKINDS})
endfunction(component__runkinds)
#
macro(component__runkind)
	#TODO# Appended value get forgotten (scoping, no doubt)
	#TODO# message(STATUS "Appending ${ARGV} to CURRENT_RUNKINDS=${CURRENT_RUNKINDS} for component ${CURRENT_COMPONENT}")
	list(APPEND CURRENT_RUNKINDS ${ARGV})
endmacro(component__runkind)


#
# Generate code for a named package.  Do this only once per package.
# This function is normally used internally, but may also be called
# explicitly for other reasons.
#
function(add_package _PKGNAME)
	list(FIND PACKAGES_GENERATED "${_PKGNAME}" _IDX)
	if (${_IDX} EQUAL -1)
		list(APPEND CURRENT_PACKAGES "${_PKGNAME}")
	endif()
endfunction(add_package)
#
macro(component__addedpackages)
	foreach(_PKGNAME IN LISTS CURRENT_PACKAGES)
		add_custom_command(
			TARGET ${_PKGNAME}-have_build
			COMMAND "${BUILDROOT_MKHERE}/${_PKGNAME}.sh" have build)
	endforeach()
endmacro(component__addedpackages)
#
macro(add_component_package _PKGNAME)
	add_package (${_PKGNAME})
	add_custom_command(
		TARGET ${CURRENT_COMPONENT}-rootfs
		PRE_LINK
		DEPENDS ${_PKGNAME}-have_build
		COMMAND "${BUILDROOT_MKHERE}/${_PKGNAME}.sh here"
		COMMAND "${BUILDROOT_MKHERE}/${_PKGNAME}.sh oslibhere"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endmacro(add_component_package)


#
# Support setting a component package list.
#
function(component_packages)
	foreach(PKG IN LISTS ARGV)
		if(NOT ${PKG}_VARIANT)
			set(${PKG}_VARIANT
				"(standard)"
				CACHE STRING "Variant of package ${PKG}")
			execute_process(
				COMMAND "${BUILDROOT_MKHERE}/${PKG}.sh" variants
				RESULT_VARIABLE _EXIT
				OUTPUT_VARIABLE ${PKG}_VARIANTS)
			if(NOT _EXIT EQUAL 0)
				set (${PKG}_VARIANTS red white blue)
				message(WARNING #TODO# FATAL_ERROR
					"Failed to find variants for component ${CURRENT_COMPONENT} package ${PKG}, exit(${_EXIT})")
			endif()
			set_property(CACHE
				${PKG}_VARIANT
				PROPERTY STRINGS
				"(standard)" ${${PKG}_VARIANTS})
		endif()
		if(NOT DEFINED ${PKG}_FLAVOUR)
			set(${PKG}_FLAVOUR
				"(standard)"
				CACHE STRING "Flavour of package ${PKG}")
			execute_process(
				COMMAND "${BUILDROOT_MKHERE}/${PKG}.sh" flavours
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
				"(standard)" ${${PKG}_FLAVOURS})
		endif()
		add_component_package(${PKG})
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
# Silently introduces the contribution kind for this component.
#
function(component_contribs _RUNKIND)
	component__runkind("${_RUNKIND}")
	list(REMOVE_AT ARGV 0)
	add_custom_target(
		${CURRENT_COMPONENT}-runkind-${_RUNKIND}
		DEPENDS ${ARGV})
	foreach (ARG IN LISTS ARGV)
		configure_file(
			"${ARG}.in"
			"${CMAKE_CURRENT_BINARY_DIR}/${ARG}"
			@ONLY)
	endforeach()
	add_dependencies(
		${CURRENT_COMPONENT}-runkind-${_RUNKIND}
		${CURRENT_COMPONENT}-runkind)
endfunction(component_contribs)


#
# Support including a subdirectory with a component.
#
macro(add_component _COMPONAME)
	set(CURRENT_COMPONENT ${_COMPONAME})
	set(CURRENT_RUNKINDS CLUMSY_EMPTY)
	list(REMOVE_AT CURRENT_RUNKINDS 0)
	set(CURRENT_PACKAGES CLUMSY_EMPTY)
	list(REMOVE_AT CURRENT_PACKAGES 0)
	#TODO# Support component targets rootfs/* and contrib/$KIND/* and all.
	#TODO# Support an ALL target for all the components added.
	add_custom_target(${_COMPONAME}-rootfs)
	add_custom_target(${_COMPONAME}-runkind
		DEPENDS ${${_COMPONAME}_RUNKIND})
	add_custom_target(${_COMPONAME} ALL
		DEPENDS ${_COMPONAME}-rootfs ${_COMPONAME}-runkind)
	component__runkinds()
	component__addedpackages()
endmacro()


#
# Include a subdirectory per component.
#
add_subdirectory(internetwide)
add_subdirectory(contrib)
add_subdirectory(local)


#
#TODO# Support installs and uninstalls?
#

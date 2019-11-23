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
		component_contribs ("${DEFAULT_RUNKIND}")
	elseif(${_IDX} EQUAL -1)
		message(WARNING
			"No contributions for runtime kind ${DEFAULT_RUNKIND} in component ${CURRENT_COMPONENT}")
	endif()
	set_property(CACHE
		${CURRENT_COMPONENT}_RUNKIND
		PROPERTY STRINGS
		${CURRENT_RUNKINDS})
endfunction(component__runkinds)
#
macro(component__runkind)
	#TODO# Appended value get forgotten (scoping, no doubt)
	#TODO# message(STATUS "Appending ${ARGV} to CURRENT_RUNKINDS=${CURRENT_RUNKINDS} for component ${CURRENT_COMPONENT}")
	list(APPEND CURRENT_RUNKINDS ${ARGV})
endmacro(component__runkind)


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
# Silently introduces the contribution kind for this component.
#
function(component_contribs _RUNKIND)
	component__runkind("${_RUNKIND}")
	add_custom_target (${CURRENT_COMPONENT}-runkind-${_RUNKIND})
	list(REMOVE_AT ARGV 0)
	foreach (ARG IN LISTS ARGV)
		#TODO# configure_file(...) --> at what phase does it run?
		configure_file(
			"${ARG}.in"
			"${CMAKE_CURRENT_BINARY_DIR}/${ARG}"
			@ONLY)
		#TODO# add_dependencies(${CURRENT_COMPONENT}-runkind-${_RUNKIND}
		#TODO# 	"${CMAKE_CURRENT_BINARY_DIR}/${ARG}")
	endforeach()
endfunction(component_contribs)


#
# Support including a subdirectory with a component.
#
macro(add_component _COMPONAME)
	set(CURRENT_COMPONENT ${_COMPONAME})
	set(CURRENT_RUNKINDS CLUMSY_EMPTY)
	list(REMOVE_AT CURRENT_RUNKINDS 0)
	add_subdirectory(${_COMPONAME})
	component__runkinds()
	#TODO# Support component targets rootfs/* and contrib/$KIND/* and all.
	#TODO# Support an ALL target for all the components added.
	add_custom_target(${_COMPONAME}-rootfs)
	add_custom_command(TARGET ${_COMPONAME}-rootfs
		POST_BUILD
		COMMAND "$BUILDROOT_MKHERE/${_COMPONAME}.sh" have build
		#TODO# Unpack tar balls or cpio archives into target rootfs
		COMMAND "$BUILDROOT_MKHERE/${_COMPONAME}.sh" tar
		COMMAND "$BUILDROOT_MKHERE/${_COMPONAME}.sh" oslibtar)
	#TODO# add_custom_target(${_COMPONAME}-runkind
	#TODO# 	DEPENDS ${_COMPONAME}-runkind-${DEFAULT_RUNKIND}})
	add_custom_target(${_COMPONAME} ALL
		DEPENDS ${_COMPONAME}-rootfs ${_COMPONAME}-runkind)
endmacro()


#
# Include a subdirectory per component.
#
add_component(arpa2dns)


#
#TODO# Support installs and uninstalls?
#

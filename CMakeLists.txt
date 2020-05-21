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

project(mkroot LANGUAGES)

include(ExternalData)


set(DEFAULT_PACKAGE_MODIFIER "(no override)")
set(BOOTSTRAP_MKHERE_MENU_DEFAULT "(mkhere symbolic link)")

set(PACKAGES_GENERATED "" CACHE INTERNAL "Packages generated so far")


#
# Support bootstrapping with locally built "mkhere" environments
#
add_subdirectory(bootstrap)


#
# Require a `mkhere` link.  Scan for mkhere/lib/stdlib to exist.
#
if(NOT DEFINED BUILDROOT_MKHERE)
	if("${BOOTSTRAP_MKHERE_MENU}" STREQUAL "")
		set(BOOTSTRAP_MKHERE_MENU "${BOOTSTRAP_MKHERE_MENU_DEFAULT}")
	endif()
	if(NOT "${BOOTSTRAP_MKHERE_MENU}" STREQUAL "${BOOTSTRAP_MKHERE_MENU_DEFAULT}")
		set(BUILDROOT_MKHERE "${CMAKE_BINARY_DIR}/${BOOTSTRAP_MKHERE_MENU}"
			CACHE STRING
			"Bootstrapping menu sets \"mkhere\" context for these \"mkroot\" builds")
	elseif(EXISTS "${CMAKE_BINARY_DIR}/mkhere/lib/stdlib")
		# Dropped support of "mkhere" in a subdirectory; manually link
		message(STATUS
			"Found mkdir structure in ${CMAKE_BINARY_DIR}/mkhere")
		set(BUILDROOT_MKHERE "${CMAKE_BINARY_DIR}/mkhere")
	else()
		message(FATAL_ERROR
			"\n\nThere is no \"mkhere\" symlink.  Please do either of the following:\n (a) Create it, pointing to a \"mkhere\" checkout in a build OS;\n (b) Define BUILDROOT_MKHERE as the \"mkhere\" checking in a build OS;\n (c) Define BOOTSTRAP_DEBIAN_MKHERE=ON and\n     BOOTSTRAP_MKHERE_MENU=\"bootstrap/debian/stable/rootfs/mkhere\".\n\n")
	endif()
	message(STATUS
		"Configured BUILDROOT_MKHERE directory ${BUILDROOT_MKHERE}")
else()
	message(STATUS
		"Using BUILDROOT_MKHERE directory ${BUILDROOT_MKHERE}")
endif()


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
macro(rootfs__addedpackages)
	foreach(_PKGNAME IN LISTS CURRENT_PACKAGES)
		#TODO# Not referenced anymore as a dependency of install
		add_custom_command(
			TARGET ${_PKGNAME}-have_build
			COMMAND "${BUILDROOT_MKHERE}/${_PKGNAME}.sh"
				"have" "osdepend" "depend" "build")
	endforeach()
endmacro(rootfs__addedpackages)
#
macro(add_rootfs_package _PKGNAME)
	add_package (${_PKGNAME})
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs
		PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E echo
			"Installing package ${_PKGNAME} into rootfs ${CURRENT_ROOTFS}"
		COMMAND ${CMAKE_COMMAND} -E env
			VERSION_${_PKGNAME}=${VERSION}
			VARIANT_${_PKGNAME}=${VARIANT}
			FLAVOUR_${_PKGNAME}=${FLAVOUR}
			"${BUILDROOT_MKHERE}/${_PKGNAME}.sh"
			"osdepend" "depend" "have" "build"
		COMMAND ${CMAKE_COMMAND} -E env
			VERSION_${_PKGNAME}=${VERSION}
			VARIANT_${_PKGNAME}=${VARIANT}
			FLAVOUR_${_PKGNAME}=${FLAVOUR}
			"${BUILDROOT_MKHERE}/${_PKGNAME}.sh"
			"cpio" "oslibcpio" "install"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endmacro(add_rootfs_package)


#
# Support setting a rootfs package list, with optional modifiers
# like VERSION=xxx VARIANT=yyy FLAVOUR=zzz before it.
#
function(rootfs_packages)
	set(VERSION "")
	set(VARIANT "")
	set(FLAVOUR "")
	set(DEFERPKG "")
	set(TRAILER " ")
	foreach(PKG IN LISTS ARGV TRAILER)
		#
		# Process prefix modifiers VERSION, VARIANT and FLAVOUR
		if("${PKG}" MATCHES "^(VERSION|VARIANT|FLAVOUR)=")
			string(SUBSTRING "${PKG}" 0  7 PKGMOD)
			string(SUBSTRING "${PKG}" 8 -1 PKGVAL)
			#DEBUG# message(STATUS "PKGMOD=${PKGMOD}= PKGVAL=${PKGVAL}= OLDVAL=${${OLDVAL}}")
			# Set the local VERSION, VARIANT or FLAVOUR variable
			set(${PKGMOD} ${PKGVAL})
			# Do not process the $PKG as a package name
			continue()
		endif()
		#
		# Only continue the loop if we have a deferred package
		if("${DEFERPKG}" STREQUAL "")
			set(DEFERPKG "${PKG}")
			continue()
		endif()
		#
		# Have cache variables for all package modifiers
		if(NOT ${CURRENT_ROOTFS}_VERSION_${DEFERPKG})
			set(${CURRENT_ROOTFS}_VERSION_${DEFERPKG}
				${DEFAULT_PACKAGE_MODIFIER}
				CACHE STRING "Version of package ${DEFERPKG}")
		endif()
		if(NOT ${CURRENT_ROOTFS}_VARIANT_${DEFERPKG})
			set(${CURRENT_ROOTFS}_VARIANT_${DEFERPKG}
				${DEFAULT_PACKAGE_MODIFIER}
				CACHE STRING "Variant of package ${DEFERPKG}")
			if(NOT DEFINED ${DEFERPKG}_VARIANTS)
				execute_process(
					COMMAND "${BUILDROOT_MKHERE}/${DEFERPKG}.sh" variants
					RESULT_VARIABLE _EXIT
					OUTPUT_VARIABLE ${DEFERPKG}_VARIANTS)
				if(NOT _EXIT EQUAL 0)
					set (${DEFERPKG}_VARIANTS red white blue)
					message(WARNING #TODO# FATAL_ERROR
						"Failed to find variants for rootfs ${CURRENT_ROOTFS} package ${DEFERPKG}, exit(${_EXIT})")
				endif()
			endif()
			set_property(CACHE
				${CURRENT_ROOTFS}_VARIANT_${DEFERPKG}
				PROPERTY STRINGS
				${DEFAULT_PACKAGE_MODIFIER}
				${${DEFERPKG}_VARIANTS})
		endif()
		if(NOT DEFINED ${CURRENT_ROOTFS}_FLAVOUR_${DEFERPKG})
			set(${CURRENT_ROOTFS}_FLAVOUR_${DEFERPKG}
				${DEFAULT_PACKAGE_MODIFIER}
				CACHE STRING "Flavour of package ${DEFERPKG}")
			if(NOT DEFINED ${DEFERPKG}_FLAVOURS)
				execute_process(
					COMMAND "${BUILDROOT_MKHERE}/${DEFERPKG}.sh" flavours
					RESULT_VARIABLE _EXIT
					OUTPUT_VARIABLE ${DEFERPKG}_FLAVOURS)
				if(NOT _EXIT EQUAL 0)
					set (${DEFERPKG}_FLAVOURS tangy sweet bitter umami)
					message(WARNING #TODO# FATAL_ERROR
						"Failed to find flavours for rootfs ${CURRENT_ROOTFS} package ${DEFERPKG}")
				endif()
			endif()
			set_property(CACHE
				${CURRENT_ROOTFS}_FLAVOUR_${DEFERPKG}
				PROPERTY STRINGS
				${DEFAULT_PACKAGE_MODIFIER}
				${${DEFERPKG}_FLAVOURS})
		endif()
		#
		# Override from cache variables
		foreach(PKGMOD IN ITEMS "VERSION" "VARIANT" "FLAVOUR")
			set(CACHEVAR "${CURRENT_ROOTFS}_${PKGMOD}_${DEFERPKG}")
			#DEBUG# message(STATUS "Cache variable ${CACHEVAR} is set to ${${CACHEVAR}}")
			if(NOT "$CACHE{${CACHEVAR}}" STREQUAL "${DEFAULT_PACKAGE_MODIFIER}")
				if(NOT "${${PKGMOD}}" STREQUAL "")
					if (NOT "${${PKGMOD}}" STREQUAL "$CACHE{${CACHEVAR}}")
						message(WARNING "Cache variable ${CACHEVAR} overrides scripted ${${PKGMOD}} to $CACHE{${CACHEVAR}}")
					endif()
					#DEBUG# message(STATUS "Package modifier ${PKGMOD} was    ${${PKGMOD}}")
				endif()
				set(${PKGMOD} "$CACHE{${CACHEVAR}}")
				#DEBUG# message(STATUS "Package modifier ${PKGMOD} is now ${${PKGMOD}}")
			endif()
		endforeach()
		#
		# Handle deferred package; defer this one
		if (NOT "${DEFERPKG}" STREQUAL "")
			# Add the (modified) package to the current rootfs
			#DEBUG# message(STATUS "During \"${PKG}\", adding \"${DEFERPKG}\" with VERSION=${VERSION}= VARIANT=${VARIANT}= FLAVOUR=${FLAVOUR}=")
			add_rootfs_package(${DEFERPKG})
			# Drop any previously defined package modifiers
			set(VERSION "")
			set(VARIANT "")
			set(FLAVOUR "")
		endif()
		set(DEFERPKG "${PKG}")
	endforeach()
endfunction(rootfs_packages)


#
# Support setting a rootfs OS package list.
#
function(rootfs_ospackages)
	list(JOIN ARGV " " OSPKGS)
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs
		PRE_BUILD
		COMMAND "${CMAKE_COMMAND}" "-E"
			"env" "FLAVOUR_ospackages=${OSPKGS}"
			"${BUILDROOT_MKHERE}/ospackages.sh"
				"osdepend"
		COMMAND "${CMAKE_COMMAND}" "-E"
			"env" "FLAVOUR_ospackages=${OSPKGS}"
			"${BUILDROOT_MKHERE}/ospackages.sh"
				"cpio" "install"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endfunction(rootfs_ospackages)


#
# Support setting a rootfs (empty) directory list.
#
function(rootfs_directories)
	set(DIRLIST )
	foreach(DIR IN LISTS ARGV)
		string(REGEX REPLACE "^/" "" RELDIR ${DIR})
		list(APPEND DIRLIST "${RELDIR}")
	endforeach()
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs
		PRE_BUILD
		COMMAND "${CMAKE_COMMAND}" -E
		"make_directory" ${DIRLIST}
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endfunction(rootfs_directories)


#
# Support setting a rootfs file list to grab from the "mkhere" environment.
#
# File names with an initial slash are retrieved with /mkhere/osfiles.sh and
# have support for filename globs.
#
# File names without inner slash are retrieved as part of the current source
# directory.
#
function(rootfs_files)
	set(OSFILES "")
	set(LOCALFILES)
	foreach(FILE IN LISTS ARGV)
		if("${FILE}" MATCHES "^/")
			string(REGEX REPLACE "[/]+" "/" PROPERFILE ${FILE})
			string(APPEND OSFILES "${PROPERFILE}//")
		elseif("${FILE}" MATCHES "/")
			message(FATAL_ERROR "Component file name ${FILE} must be either absolute or local")
		elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${FILE}")
			list(APPEND LOCALFILES "${FILE}")
		else()
			message(FATAL_ERROR "Not sure where to find coponent file ${FILE}")
		endif()
	endforeach()
	if(NOT "${OSFILES}" STREQUAL "")
		add_custom_command(
			TARGET ${CURRENT_ROOTFS}-rootfs
			PRE_BUILD
			COMMAND "${CMAKE_COMMAND}" "-E"
				"env" "FLAVOUR_osfiles=\"${OSFILES}\""
				"${BUILDROOT_MKHERE}/osfiles.sh"
					"osdepend" "depend" "have" "build"
			COMMAND "${CMAKE_COMMAND}" "-E"
				"env" "FLAVOUR_osfiles=\"${OSFILES}\""
				"${BUILDROOT_MKHERE}/osfiles.sh"
					"cpio" "oslibcpio" "install"
			WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
	endif()
	foreach(LOCALFILE IN LISTS LOCALFILES)
		add_custom_command(
			TARGET ${CURRENT_ROOTFS}-rootfs
			PRE_BUILD
			COMMAND "${CMAKE_COMMAND}" "-E"
				"copy"
				"${CMAKE_CURRENT_SOURCE_DIR}/${LOCALFILE}"
				"${CMAKE_CURRENT_BINARY_DIR}/rootfs/${LOCALFILE}")
	endforeach()
endfunction(rootfs_files)


#
#TODO# Support setting a rootfs kernel module list???
#
function(rootfs_kernel_modules)
	message(FATAL_ERROR "rootfs_kernel_modules() is not yet implemented")
endfunction(rootfs_kernel_modules)


#
# Support downloads of URLs into the root directory for the rootfs.
#
function(rootfs_downloads)
	foreach(URL IN LISTS ARGV)
		string(REGEX REPLACE
			"^.*/"
			""
			BASENAME
			"${URL}")
		message(STATUS
			"Downloading /${BASENAME} in ${CURRENT_ROOTFS} from ${URL}")
		add_custom_command(
			TARGET ${CURRENT_ROOTFS}-rootfs
			PRE_BUILD
			COMMAND "${CMAKE_COMMAND}"
				-P "${CMAKE_SOURCE_DIR}/FetchFiles.cmake"
				"${URL}"
			COMMAND "${CMAKE_COMMAND}"
				-E copy
				"${CMAKE_CURRENT_BINARY_DIR}/FetchedFiles/${BASENAME}"
				"${CMAKE_CURRENT_BINARY_DIR}/rootfs/${BASENAME}")
	endforeach()
endfunction(rootfs_downloads)


#
# Support setting fixup bash scripts to run on the rootfs.
# Note: We append a .sh extension for best portability
#
function(rootfs_fixups)
	foreach(FIX IN LISTS ARGV)
		set(FIXSCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/${FIX}")
		if(NOT EXISTS "${FIXSCRIPT}")
			set(FIXSCRIPT "${CMAKE_SOURCE_DIR}/fixup/${FIX}")
		endif()
		if(NOT EXISTS "${FIXSCRIPT}")
			message(FATAL_ERROR "Fixup script ${FIX} not found")
		endif()
		add_custom_command(
			TARGET ${CURRENT_ROOTFS}-rootfs
			POST_BUILD
			COMMAND "${CMAKE_COMMAND}"
				-P "${CMAKE_SOURCE_DIR}/RunFixup.cmake"
				"${CMAKE_CURRENT_BINARY_DIR}/rootfs"
				"${FIXSCRIPT}"
			RESULT_VARIABLE _EXIT
		)
		if(NOT ${_EXIT} EQUAL 0)
			message(FATAL_ERROR "Failed to run fixup ${FIX}")
		endif()
	endforeach()
endfunction(rootfs_fixups)

#
# Support adding contributed files per kind of contrib.
#
function(rootfs_runkind _RUNKIND)
	list(REMOVE_AT ARGV 0)
	set(INDEX "${CMAKE_CURRENT_BINARY_DIR}/${_RUNKIND}.index")
	file(WRITE "${INDEX}" "rootfs/\n")
	add_custom_target(
		${CURRENT_ROOTFS}-runkind-${_RUNKIND}
		# DEPENDS ${ARGV})
	)
	if(EXISTS "${CMAKE_SOURCE_DIR}/runkind/${_RUNKIND}.sh")
		add_custom_command(
			TARGET ${CURRENT_ROOTFS}-runkind-${_RUNKIND}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND}
				-P "${CMAKE_SOURCE_DIR}/RunKind.cmake"
				"${CMAKE_SOURCE_DIR}/runkind/${_RUNKIND}.sh"
				"${CMAKE_CURRENT_BINARY_DIR}")
	else()
		message(WARNING "Missing support script runkind/${_RUNKIND}.sh")
	endif()
	#TODO# Following configure_file sequence should be run for that target
	foreach (ARG IN LISTS ARGV)
		configure_file(
			"${ARG}.in"
			"${CMAKE_CURRENT_BINARY_DIR}/${ARG}"
			@ONLY)
		file(APPEND "${INDEX}" "${ARG}\n")
	endforeach()
	add_dependencies(
		${CURRENT_ROOTFS}-runkind
		${CURRENT_ROOTFS}-runkind-${_RUNKIND})
	add_dependencies(
		${CURRENT_ROOTFS}-runkind-${_RUNKIND}
		${CURRENT_ROOTFS}-rootfs)
endfunction(rootfs_runkind)


#
# Support including a subdirectory with a rootfs.
#
macro(add_rootfs _COMPONAME)
	set(CURRENT_ROOTFS ${_COMPONAME})
	set(CURRENT_PACKAGES CLUMSY_EMPTY)
	list(REMOVE_AT CURRENT_PACKAGES 0)
	# Support rootfs target rootfs/*
	add_custom_target(${_COMPONAME}-rootfs)
	execute_process (COMMAND "${CMAKE_COMMAND}" "-E"
		"make_directory" "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
	# Support an ALL target for all the rootfs's as a whole.
	rootfs__addedpackages()
	# Support rootfs target $KIND_FILE
	add_custom_target(${_COMPONAME}-runkind)
	add_custom_target(${_COMPONAME} ALL
		DEPENDS ${_COMPONAME}-rootfs ${_COMPONAME}-runkind)
endmacro()


#
# Support including terminfo(5) database files.
#
function(rootfs_terminfo)
	list(JOIN ARGV " " FLAVOUR)
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs
		PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E env
			FLAVOUR_osterminfo=${FLAVOUR}
			"${BUILDROOT_MKHERE}/osterminfo.sh"
			"osdepend" "depend" "have" "build"
		COMMAND ${CMAKE_COMMAND} -E env
			FLAVOUR_osterminfo=${FLAVOUR}
			"${BUILDROOT_MKHERE}/osterminfo.sh"
			"cpio" "install"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endfunction(rootfs_terminfo)


#
# Support including commands from the underlying build root.
#
function(rootfs_oscommands)
	list(JOIN ARGV " " FLAVOUR)
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs
		PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E env
			FLAVOUR_osterminfo=${FLAVOUR}
			"${BUILDROOT_MKHERE}/oscommands.sh"
			"osdepend" "depend" "have" "build"
		COMMAND ${CMAKE_COMMAND} -E env
			FLAVOUR_osterminfo=${FLAVOUR}
			"${BUILDROOT_MKHERE}/oscommands.sh"
			"cpio" "oslibcpio" "install"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endfunction(rootfs_oscommands)


#
# Support including libraries from the underlying build root.
#
function(rootfs_oslibraries)
	list(JOIN ARGV " " FLAVOUR)
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs
		PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E env
			FLAVOUR_osterminfo=${FLAVOUR}
			"${BUILDROOT_MKHERE}/oslibraries.sh"
			"osdepend" "depend" "have" "build"
		COMMAND ${CMAKE_COMMAND} -E env
			FLAVOUR_osterminfo=${FLAVOUR}
			"${BUILDROOT_MKHERE}/oslibraries.sh"
			"cpio" "oslibcpio" "install"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endfunction(rootfs_oslibraries)


#
# Support including one or more kernel versions, along with named modules.
# The format is rootfs_kernel(MOD1 MOD2 MOD3).  Kernel version information
# can be set in script or cache variables:
#  - ${xxx_VERSION_oskernel} for a kernel version number
#  - ${xxx_VARIANT_oskernel} for kernel additional words/flags
#  - ${xxx_FLAVOUR_oskernelmodules} for a space-separated module name list
#TODO# Support VERSION= and VARIANT= options in the beginning.
#
# The intention of this functionality is intended to not be Linux-specific,
# since most operating systems have a notion of a kernel image to be loaded
# during boot, and a file system that can hold additional modules for it.
#
# It is possible to add no modules and simply use rootfs_kernel() to
# retrieve the current kernel or kernels.
#
function(rootfs_kernel)
	if(NOT DEFINED ${CURRENT_ROOTFS}_VERSION_oskernel)
		set(${CURRENT_ROOTFS}_VERSION_oskernel
			${DEFAULT_PACKAGE_MODIFIER}
			CACHE STRING "Version of kernel")
	endif()
	if(NOT DEFINED ${CURRENT_ROOTFS}_VARIANT_oskernel)
		set(${CURRENT_ROOTFS}_VARIANT_oskernel
			${DEFAULT_PACKAGE_MODIFIER}
			CACHE STRING "Variant restrictions of kernel")
	endif()
	set(VERSION ${${CURRENT_ROOTFS}_VERSION_oskernel})
	set(VARIANT ${${CURRENT_ROOTFS}_VARIANT_oskernel})
	if("${VERSION}" STREQUAL "${DEFAULT_PACKAGE_MODIFIER}")
		set(VERSION)
	endif()
	if("${VARIANT}" STREQUAL "${DEFAULT_PACKAGE_MODIFIER}")
		set(VARIANT)
	endif()
	while("${ARGV}" MATCHES "^(VERSION|VARIANT)=")
		list(GET ARGV 0 KRNARG)
		list(REMOVE_AT ARGV 0)
		string(SUBSTRING "${KRNARG}" 0  7 KRNMOD)
		string(SUBSTRING "${KRNARG}" 8 -1 KRNVAL)
		if(NOT "${${KRNMOD}}" STREQUAL "")
			message(WARNING "Cache variable ${CURRENT_ROOTFS}_oskernel_${KRNMOD} overrides scripted ${KRNVAL} to ${${KRNMOD}}")
		else()
			set(${KRNMOD} "${KRNVAL}")
		endif()
	endwhile()
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs  #TODO#ELSEWHERE#
		PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E env
			VERSION_oskernel=${VERSION}
			VARIANT_oskernel=${VARIANT}
			"${BUILDROOT_MKHERE}/oskernel.sh"
			"osdepend" "depend" "have" "build"
		COMMAND ${CMAKE_COMMAND} -E env
			VERSION_oskernel=${VERSION}
			VARIANT_oskernel=${VARIANT}
			"${BUILDROOT_MKHERE}/oskernel.sh"
			"cpio" "install"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
	list(JOIN ARGV " " FLAVOUR)
	add_custom_command(
		TARGET ${CURRENT_ROOTFS}-rootfs
		PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E env
			VERSION_oskernel=${VERSION}
			VARIANT_oskernel=${VARIANT}
			FLAVOUR_oskernelmodules=${FLAVOUR}
			"${BUILDROOT_MKHERE}/oskernelmodules.sh"
			"osdepend" "depend" "have" "build"
		COMMAND ${CMAKE_COMMAND} -E env
			VERSION_oskernel=${VERSION}
			VARIANT_oskernel=${VARIANT}
			FLAVOUR_oskernelmodules=${FLAVOUR}
			"${BUILDROOT_MKHERE}/oskernelmodules.sh"
			"cpio" "install"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rootfs")
endfunction(rootfs_kernel)


#
# Include a subdirectory per rootfs.
#
add_subdirectory(internetwide)
add_subdirectory(contrib)
add_subdirectory(local)


#
#TODO# Support installs and uninstalls?
#

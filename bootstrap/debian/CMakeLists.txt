# Debian as a build OS (includes variants)
#
# We install Debian in a rootfs with "debootstrap", which we download
# from source.  Since it is a shell script, this should work out fine.
#
# We install a core set of packages, and most importantly, we clone
# the "mkhere" Git repository in the build OS root directory, so it
# can be symolically linked from other rootfs build setups as their
# "mkhere".  Hence the name "bootstrap" for this class of rootfs.
#
# From: Rick van Rein <rick@openfortress.nl>


# Locate the GIT package (needed for bootstrapping "mkhere")
#
set(MKHERE_ORIGIN "https://github.com/arpa2/mkhere")
find_package(Git)
if(NOT GIT_FOUND)
	message(FATAL_ERROR "Need git for bootstrapping")
endif()


# Make sure to have the DEBOOTSTRAP_VERSION and DEBOOTSTRAP_SUITE strings
#
if(NOT DEFINED DEBOOTSTRAP_VERSION)
	set(DEBOOTSTRAP_VERSION
		"1.0.116"
		CACHE STRING
		"Debian's debootstrap script version to fetch")
endif()
if(NOT DEFINED DEBOOTSTRAP_SUITE)
	set(DEBOOTSTRAP_SUITE
		"stable"
		CACHE STRING
		"Debian's debootstrap suite to install")
endif()


# Tell the parent CMakeLists.txt about the DEBIAN_ROOTFS to use
#
set(DEBIAN_ROOTFS
	"bootstrap/debian/${DEBOOTSTRAP_SUITE}/rootfs"
	PARENT_SCOPE)


# BIG IF -- whether to actually install a Debian
#
option(BOOTSTRAP_DEBIAN_MKHERE "Bootstrap via \"mkhere\" on Debian, Ubuntu, Tanglu or Kali" OFF)
if(BOOTSTRAP_DEBIAN_MKHERE)


# Retrieve the debootstrap tar ball, if a version was accepted
#
	set(DEBOOTSTRAP_TARBALL "${CMAKE_CURRENT_BINARY_DIR}/debootstrap_${DEBOOTSTRAP_VERSION}.tar.gz")
	if(NOT EXISTS "${DEBOOTSTRAP_TARBALL}")
		file(DOWNLOAD
			"http://deb.debian.org/debian/pool/main/d/debootstrap/debootstrap_${DEBOOTSTRAP_VERSION}.tar.gz"
			"${DEBOOTSTRAP_TARBALL}"
		)
	endif()


# Unpack the tar ball into a directory
#
	if(EXISTS "${DEBOOTSTRAP_TARBALL}")
		set(DEBOOTSTRAP_DIR "${CMAKE_CURRENT_BINARY_DIR}/debootstrap-${DEBOOTSTRAP_VERSION}")
		if(NOT IS_DIRECTORY "${DEBOOTSTRAP_DIR}")
			execute_process(
				COMMAND "${CMAKE_COMMAND}"
					-E tar xzf
					"${DEBOOTSTRAP_TARBALL}"
				WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
			)
		endif()
	endif()


# Run the debootstrap script against the rootfs
#
	if(IS_DIRECTORY "${DEBOOTSTRAP_DIR}")
		#TODO# Iterate over a list of suites entered... how?
		set(DEBIAN_ROOTFS
			"${CMAKE_CURRENT_BINARY_DIR}/${DEBOOTSTRAP_SUITE}/rootfs")
		if(IS_DIRECTORY "${DEBIAN_ROOTFS}/mkhere")
			message(STATUS
				"Reusing bootstrapping directory ${DEBIAN_ROOTFS}")
		else()
			execute_process(
				COMMAND "${CMAKE_COMMAND}"
					-E remove_directory
					"${DEBIAN_ROOTFS}"
			)
			execute_process(
				COMMAND "${CMAKE_COMMAND}"
					-E make_directory
					"${DEBIAN_ROOTFS}"
				RESULT_VARIABLE _EXIT
			)
			if(NOT _EXIT EQUAL 0)
				execute_process(
					COMMAND "${CMAKE_COMMAND}"
						-E remove_directory
						"${DEBIAN_ROOTFS}"
				)
				message(FATAL_ERROR
					"Failed to create rootfs for debian in ${DEBIAN_ROOTFS}")
			endif()
			execute_process(
				COMMAND "${CMAKE_COMMAND}"
					-E env
					"DEBOOTSTRAP_DIR=${DEBOOTSTRAP_DIR}"
					"${DEBOOTSTRAP_DIR}/debootstrap"
					"--variant=buildd"
					"--include=cmake,git,wget,cpio"
					"${DEBOOTSTRAP_SUITE}"
					"${DEBIAN_ROOTFS}"
				RESULT_VARIABLE _EXIT
			)
			if(NOT _EXIT EQUAL 0)
				execute_process(
					COMMAND "${CMAKE_COMMAND}"
						-E remove_directory
						"${DEBIAN_ROOTFS}"
				)
				message(FATAL_ERROR
					"Failed to run debootstrap ${DEBOOTSTRAP_SUITE} ${DEBIAN_ROOTFS}")
			endif()
			execute_process(
				COMMAND "${GIT_EXECUTABLE}"
					clone
					"${MKHERE_ORIGIN}"
					"${DEBIAN_ROOTFS}/mkhere"
				RESULT_VARIABLE _EXIT
			)
			if(NOT _EXIT EQUAL 0)
				execute_process(
					COMMAND "${CMAKE_COMMAND}"
						-E remove_directory
						"${DEBIAN_ROOTFS}"
				)
				message(FATAL_ERROR
					"Failed to install /mkhere into debian rootfs ${DEBIAN_ROOTFS}")
			endif()
		endif()
	endif()


# BIG IF ends here
#
endif()

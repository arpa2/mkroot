# Run a fixup script -- called with cmake -P.
#
# The new root directory is the first paramater, the script is
# the second (which will be copied to /tmp) and any arguments follow.
#
# This is a plain "chroot" call on POSIX systems, but that is not
# possible on Window.  The trick proposed by mansoft.nl is to use
# the Windows subst command on the one[0] non-POSIX platform.
#
# [0] Well, as long as it lasts.  Windows is quickly adopting POSIX.
#
# From: Rick van Rein <rick@openfortress.nl>


cmake_minimum_required(VERSION 3.13)

# Derive values for ARGV and ARGC as one would expect
#
set(ARGV)
math(EXPR ARGC ${CMAKE_ARGC}-1)
foreach(ARGI RANGE 3 ${ARGC})
	set(ARGV ${ARGV} "${CMAKE_ARGV${ARGI}}")
endforeach()
list(LENGTH ARGV ARGC)


# Desire at least <rootdir> <fixupscript> arguments
#
if(${ARGC} LESS 2)
	message(FATAL_ERROR "Required arguments: <rootdir> <fixupscript> [<args>...]")
endif()
list(GET ARGV 0 ROOTDIR)
list(GET ARGV 1 FIXUPSCRIPT)
list(REMOVE_AT ARGV 0 1)
list(LENGTH ARGV ARGC)


# Test that the ${ROOTDIR} exists, and so does the ${FIXUPSCRIPT}
#
if(NOT IS_DIRECTORY "${ROOTDIR}")
	message(FATAL_ERROR "Directory ${ROOTDIR} not found")
endif()
if(NOT EXISTS "${FIXUPSCRIPT}")
	message(FATAL_ERROR "Fixup script ${FIXUPSCRIPT} not found")
endif()


# Copy the ${FIXUPSCRIPT} into ${ROOTDIR}/tmp
#
get_filename_component(TMPFIX "${FIXUPSCRIPT}" NAME)
string(PREPEND TMPFIX "/tmp/")
execute_process(
	COMMAND "${CMAKE_COMMAND}"
		-E copy
		"${FIXUPSCRIPT}"
		"${ROOTDIR}${TMPFIX}"
	RESULT_VARIABLE _EXIT)
if(NOT ${_EXIT} EQUAL 0)
	message(FATAL_ERROR "Failed to copy ${FIXUPSCRIPT} to chroot's ${TMPFIX}")
endif()



# Run the ${FIXUPSCRIPT} after a chroot to ${ROOTDIR}
#
execute_process(
	COMMAND "chroot" "${ROOTDIR}" "${TMPFIX}" ${ARGV}
	RESULT_VARIABLE _EXIT)
if(NOT ${_EXIT} EQUAL 0)
	message(FATAL_ERROR "Fixup script ${TMPFIX} returned ${_EXIT}")
endif()


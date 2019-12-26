# RunKind.cmake -- Run the support script for a runkind
#
# The various runkinds have names like PXE, and there are
# scripts for each in runkind/ with a .sh attached.  These
# are bash scripts that should be run by CMake.  The .sh
# extension is helpful on Windows, but the scripts also
# use the customary hash-bang notation and have execute
# permissions set.
#
# The idea is that these scripts should run for each of
# the runkinds defined for them.  By that time, the list
# of values will have been recorded in a runkind-named
# and .index-extended file in the binary build directory.
# Because, unlike fixup scripts, a runkind script is run
# by the bash of the host that builds with mkroot.
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

# Desire at least <targetdir> <runkindscript> arguments
#
if(${ARGC} LESS 2)
	message(FATAL_ERROR "Required arguments: <runkindscript> <targetdir> [<args>...]")
endif()
list(GET ARGV 0 RUNKINDSCRIPT)
list(GET ARGV 1 TARGETDIR)
list(REMOVE_AT ARGV 0 1)
list(LENGTH ARGV ARGC)

# Run the script with the <targetdir> as working directory
#
execute_process(
	COMMAND "${RUNKINDSCRIPT}" "." ${ARGV}
	RESULT_VARIABLE _EXIT
	WORKING_DIRECTORY "${TARGETDIR}")
if(NOT ${_EXIT} EQUAL 0)
	message(FATAL_ERROR "Runkind script ${RUNKINDSCRIPT} returned ${_EXIT}")
endif()


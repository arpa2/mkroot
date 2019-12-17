# Fetch a remote object from a URL using url(DOWNLOAD...)
#
# This script can be called from a script as part of a target, with
# ${CMAKE_PROGRAM} -P .../FetchFiles.cmake ${URL}...
#
# Downloads are cached in a subdirectory FetchedFiles/ under the
# current binary directory.
#
# From: Rick van Rein <rick@openfortress.nl>



cmake_minimum_required(VERSION 3.13)


# Require at least one URL after "cmake -P <script>"
#
if(${CMAKE_ARGC} LESS 3)
	message(FATAL_ERROR "Please specify at least one URL to fetch")
endif()

# Iterate URLs, downloading each
math(EXPR ARGC ${CMAKE_ARGC}-1)
foreach(ARGI RANGE 3 ${ARGC})
	set(URL ${CMAKE_ARGV${ARGI}})
	string(REGEX REPLACE
		"^.*/"
		""
		FILENAME
		"${URL}")
	if("${FILENAME}" STREQUAL "")
		message(FATAL "Cannot derive file name from ${URL}")
	endif()
	set(OUTFILE "${CMAKE_CURRENT_BINARY_DIR}/FetchedFiles/${FILENAME}")
	if(NOT EXISTS "${OUTFILE}")
		message(STATUS "FetchFile ${FILENAME} from ${URL}")
		file(DOWNLOAD "${URL}" "${OUTFILE}")
	else()
		message(STATUS "FetchedFiles/${FILENAME} used for ${URL}")
	endif()
	file(READ "${OUTFILE}" OUTBIN)
	if("${OUTBIN}" STREQUAL "")
		message(FATAL "FetchFile could not download from ${URL}")
	endif()
endforeach()

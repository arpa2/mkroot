# Local Extensions to the InternetWide Architecture
#
# These components may be useful in combination with the components
# in the "real" internetwide components.  They are customarily built,
# but will not be included in the mainstream distribution.  Having
# local extensions in a separate place avoids the need for local use
# cases to modify existing components.
#
# From: Rick van Rein <rick@openfortress.nl>


file(GLOB SUBDIRS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*")

foreach(SUBDIR ${SUBDIRS})
	if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SUBDIR}/CMakeLists.txt")
		option("LOCAL_${SUBDIR}" "local/${SUBDIR} extension" ON)
		if(CONTRIB_MINICOM_TOOL)
			add_subdirectory ("${SUBDIR}")
		endif()
	endif()
endforeach()


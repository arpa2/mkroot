# External Contributions to the InternetWide Architecture
#
# These components may be useful in combination with the components
# in the "real" internetwide components.  They are not built by
# default.
#
# From: Rick van Rein <rick@openfortress.nl>


option(CONTRIB_MINICOM_TOOL "Minicom Tool (also a nice demo)" OFF)
if(CONTRIB_MINICOM_TOOL)
	add_subdirectory(minicom-tool)
endif()

option(CONTRIB_WEB_NGINX "Web server: Nginx" OFF)
if(CONTRIB_WEB_NGINX)
	add_subdirectory(web-nginx)
endif()

option(CONTRIB_WEB_APACHE "Web server: Apache" OFF)
if(CONTRIB_WEB_APACHE)
	add_subdirectory(web-apache)
endif()

# option(CONTRIB_contrib1 "Contribution #1" OFF)
# if(CONTRIB_contrib1)
# 	add_subdirectory(contrib1)
# endif()

# option(CONTRIB_contrib2 "Contribution #2" OFF)
# if(CONTRIB_contrib2)
# 	add_subdirectory(contrib2)
# endif()

# option(CONTRIB_contrib3 "Contribution #3" OFF)
# if(CONTRIB_contrib3)
# 	add_subdirectory(contrib3)
# endif()

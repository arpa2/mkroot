# Components of the InternetWide Architecture
#
# See: http://internetwide.org/tag/architecture.html
#
# From: Rick van Rein <rick@openfortress.nl>


#
# Declare bridges; they will be assumed to exist and components
# will link to one or more of them.  Each is setup in a netns
# which is also assumed to exist and already hold the bridge.
#

function(declare_bridge _SYMBOLICNAME _DESCR)
	set (IWO_${_SYMBOLICNAME}_BRIDGE "" CACHE STRING "${_DESCR} (empty for non-existent)")
	set (IWO_${_SYMBOLICNAME}_NETNS  "" CACHE STRING "Network Namespace for bridge ${_SYMBOLICNAME} (empty if none)")
endfunction(declare_bridge)

macro(use_bridge _VARNAME _SYMBOLICNAME)
	if ("${IWO_${_SYMBOLICNAME}_BRIDGE}" STREQUAL "")
		message (FATAL_ERROR "The bridge name IWO_${_SYMBOLICNAME}_BRIDGE is required for ${CURRENT_ROOTFS}")
	else ()
		set (${_VARNAME} "${IWO_${_SYMBOLICNAME}_BRIDGE}")
		if ("${IWO_${_SYMBOLICNAME}_NETNS}" STREQUAL "")
			set (${_VARNAME}_NETNS)
			set (${_VARNAME}_NETNS_EXEC)
		else ()
			set (${_VARNAME}_NETNS " netns ${IWO_${_SYMBOLICNAME}_NETNS}")
			set (${_VARNAME}_NETNS_EXEC "ip netns exec ${IWO_${_SYMBOLICNAME}_NETNS} ")
		endif ()
	endif ()
endmacro(use_bridge)

declare_bridge (iwo0pub "Public network connection")
declare_bridge (iwo0dmz "DeMilitarised Zone")
declare_bridge (iwo0bck "Backend connectivity network")
declare_bridge (iwo0plg "Plugin services")
declare_bridge (iwo0ngb "Neighbouring hosts, same realm")
declare_bridge (iwo0sit "Remote sites, same realm")
declare_bridge (iwo0ctl "Control automation")
declare_bridge (iwo0adm "Administrative access")


#
# Building instructions for components of the InternetWide Architecture
#
add_subdirectory(arpa2dns)
add_subdirectory(kip)

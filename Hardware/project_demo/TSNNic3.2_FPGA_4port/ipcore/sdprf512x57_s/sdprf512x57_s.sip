set_global_assignment -entity "sdprf512x57_s" -library "lib_sdprf512x57_s" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "sdprf512x57_s" -library "lib_sdprf512x57_s" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "sdprf512x57_s" -library "lib_sdprf512x57_s" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_sdprf512x57_s" -name SPD_FILE [file join $::quartus(sip_path) "sdprf512x57_s.spd"]
set_global_assignment -library "lib_sdprf512x57_s" -name MISC_FILE [file join $::quartus(sip_path) "../sdprf512x57_s.qsys"]

set_global_assignment -library "lib_sdprf512x57_s" -name MISC_FILE [file join $::quartus(sip_path) "sim/sdprf512x57_s.v"]
set_global_assignment -library "lib_sdprf512x57_s" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_191/sim/sdprf512x57_s_ram_2port_191_xvvq7qa.v"]

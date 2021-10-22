set_global_assignment -entity "asdprf16x8_rq" -library "lib_asdprf16x8_rq" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "asdprf16x8_rq" -library "lib_asdprf16x8_rq" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "asdprf16x8_rq" -library "lib_asdprf16x8_rq" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_asdprf16x8_rq" -name SPD_FILE [file join $::quartus(sip_path) "asdprf16x8_rq.spd"]
set_global_assignment -library "lib_asdprf16x8_rq" -name MISC_FILE [file join $::quartus(sip_path) "../asdprf16x8_rq.qsys"]

set_global_assignment -library "lib_asdprf16x8_rq" -name MISC_FILE [file join $::quartus(sip_path) "sim/asdprf16x8_rq.v"]
set_global_assignment -library "lib_asdprf16x8_rq" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_191/sim/asdprf16x8_rq_ram_2port_191_2sgz4hi.v"]

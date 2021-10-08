set_global_assignment -entity "RAM9_512" -library "lib_RAM9_512" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "RAM9_512" -library "lib_RAM9_512" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "RAM9_512" -library "lib_RAM9_512" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_RAM9_512" -name SPD_FILE [file join $::quartus(sip_path) "RAM9_512.spd"]
set_global_assignment -library "lib_RAM9_512" -name MISC_FILE [file join $::quartus(sip_path) "../RAM9_512.qsys"]

set_global_assignment -library "lib_RAM9_512" -name MISC_FILE [file join $::quartus(sip_path) "sim/RAM9_512.v"]
set_global_assignment -library "lib_RAM9_512" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_191/sim/RAM9_512_ram_2port_191_fb4km7q.v"]

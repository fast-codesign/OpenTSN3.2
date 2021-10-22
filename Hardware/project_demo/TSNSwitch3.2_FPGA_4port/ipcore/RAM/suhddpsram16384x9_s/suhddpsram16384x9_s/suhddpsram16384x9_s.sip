set_global_assignment -entity "suhddpsram16384x9_s" -library "lib_suhddpsram16384x9_s" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "suhddpsram16384x9_s" -library "lib_suhddpsram16384x9_s" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "suhddpsram16384x9_s" -library "lib_suhddpsram16384x9_s" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_suhddpsram16384x9_s" -name SPD_FILE [file join $::quartus(sip_path) "suhddpsram16384x9_s.spd"]
set_global_assignment -library "lib_suhddpsram16384x9_s" -name MISC_FILE [file join $::quartus(quartus_rootpath) "bin64/suhddpsram16384x9_s/suhddpsram16384x9_s.qsys"]

set_global_assignment -library "lib_suhddpsram16384x9_s" -name MISC_FILE [file join $::quartus(sip_path) "sim/suhddpsram16384x9_s.v"]
set_global_assignment -library "lib_suhddpsram16384x9_s" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_191/sim/suhddpsram16384x9_s_ram_2port_191_emqbfsi.v"]

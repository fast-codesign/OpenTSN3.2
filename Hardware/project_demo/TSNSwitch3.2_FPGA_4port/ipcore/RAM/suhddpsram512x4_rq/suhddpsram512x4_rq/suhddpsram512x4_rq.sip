set_global_assignment -entity "suhddpsram512x4_rq" -library "lib_suhddpsram512x4_rq" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "suhddpsram512x4_rq" -library "lib_suhddpsram512x4_rq" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "suhddpsram512x4_rq" -library "lib_suhddpsram512x4_rq" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_suhddpsram512x4_rq" -name SPD_FILE [file join $::quartus(sip_path) "suhddpsram512x4_rq.spd"]
set_global_assignment -library "lib_suhddpsram512x4_rq" -name MISC_FILE [file join $::quartus(quartus_rootpath) "bin64/suhddpsram512x4_rq/suhddpsram512x4_rq.qsys"]

set_global_assignment -library "lib_suhddpsram512x4_rq" -name MISC_FILE [file join $::quartus(sip_path) "sim/suhddpsram512x4_rq.v"]
set_global_assignment -library "lib_suhddpsram512x4_rq" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_191/sim/suhddpsram512x4_rq_ram_2port_191_gytxvfq.v"]

set_global_assignment -entity "suhddpsram65536x134_s" -library "lib_suhddpsram65536x134_s" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "suhddpsram65536x134_s" -library "lib_suhddpsram65536x134_s" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "suhddpsram65536x134_s" -library "lib_suhddpsram65536x134_s" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_suhddpsram65536x134_s" -name SPD_FILE [file join $::quartus(sip_path) "suhddpsram65536x134_s.spd"]
set_global_assignment -library "lib_suhddpsram65536x134_s" -name MISC_FILE [file join $::quartus(quartus_rootpath) "bin64/suhddpsram65536x134_s/suhddpsram65536x134_s.qsys"]

set_global_assignment -library "lib_suhddpsram65536x134_s" -name MISC_FILE [file join $::quartus(sip_path) "sim/suhddpsram65536x134_s.v"]
set_global_assignment -library "lib_suhddpsram65536x134_s" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_191/sim/suhddpsram65536x134_s_ram_2port_191_pu2i72y.v"]

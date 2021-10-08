set_global_assignment -entity "suhddpsram1024x8_rq" -library "lib_suhddpsram1024x8_rq" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "suhddpsram1024x8_rq" -library "lib_suhddpsram1024x8_rq" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "suhddpsram1024x8_rq" -library "lib_suhddpsram1024x8_rq" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_suhddpsram1024x8_rq" -name SPD_FILE [file join $::quartus(sip_path) "suhddpsram1024x8_rq.spd"]
set_global_assignment -library "lib_suhddpsram1024x8_rq" -name MISC_FILE [file join $::quartus(quartus_rootpath) "bin64/suhddpsram1024x8_rq/suhddpsram1024x8_rq.qsys"]

set_global_assignment -library "lib_suhddpsram1024x8_rq" -name MISC_FILE [file join $::quartus(sip_path) "sim/suhddpsram1024x8_rq.v"]
set_global_assignment -library "lib_suhddpsram1024x8_rq" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_191/sim/suhddpsram1024x8_rq_ram_2port_191_go2l72y.v"]

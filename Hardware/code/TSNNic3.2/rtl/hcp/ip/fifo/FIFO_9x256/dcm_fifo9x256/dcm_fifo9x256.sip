set_global_assignment -entity "dcm_fifo9x256" -library "lib_dcm_fifo9x256" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "dcm_fifo9x256" -library "lib_dcm_fifo9x256" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "dcm_fifo9x256" -library "lib_dcm_fifo9x256" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_dcm_fifo9x256" -name SPD_FILE [file join $::quartus(sip_path) "dcm_fifo9x256.spd"]
set_global_assignment -library "lib_dcm_fifo9x256" -name MISC_FILE [file join $::quartus(sip_path) "../dcm_fifo9x256.qsys"]

set_global_assignment -library "lib_dcm_fifo9x256" -name MISC_FILE [file join $::quartus(sip_path) "sim/dcm_fifo9x256.v"]
set_global_assignment -library "lib_dcm_fifo9x256" -name MISC_FILE [file join $::quartus(sip_path) "fifo_191/sim/dcm_fifo9x256_fifo_191_53aeptq.v"]

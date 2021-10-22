#ifndef _BASIC_CFG_H__
#define _BASIC_CFG_H__


#include "../net_init/net_init.h"



int basic_cfg(u8 *pkt,u16 pkt_len);

int init_cfg_fun(u8 node_idx);
u16 get_imac_from_tsntag(u8 *tsntag);
int send_start_report_tsninsight(u16 cur_state,u16 state_info,u16 imac);
void fwrite_file(u16 imac,u64 hw_version);

int init_test_fun();
#endif




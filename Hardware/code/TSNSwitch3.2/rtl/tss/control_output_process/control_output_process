// Copyright (C) 1953-2021 NUDT
// Verilog module name - control_transmit_process 
// Version: V3.2.0.20210722
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         transmit process of host.
//             -top module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module control_output_process
(
       i_clk,
       i_rst_n,

       i_host_gmii_tx_clk,
       i_gmii_rst_n_host,
       
       iv_pkt_type_ctrl,
	   iv_pkt_bufid_ctrl,
       i_mac_entry_hit_ctrl,
       iv_pkt_inport_ctrl,
       i_pkt_bufid_wr_ctrl,
       
       ov_pkt_bufid,
       o_pkt_bufid_wr,
       i_pkt_bufid_ack, 
       
       ov_pkt_raddr,
       o_pkt_rd,
       i_pkt_raddr_ack,
       
       iv_pkt_data,
       i_pkt_data_wr,

       o_pkt_cnt_pulse, 
       o_fifo_overflow_pulse,       
       
       ov_gmii_txd,
       o_gmii_tx_en,
       o_gmii_tx_er,
       o_gmii_tx_clk,
       
       iv_syned_global_time,
       i_timer_rst,
       
       hoi_state,
       bufid_state,
       pkt_read_state    
);

// I/O
// clk & rst
input                  i_clk;   
input                  i_rst_n;
// clock of gmii_tx
input                  i_host_gmii_tx_clk;
input                  i_gmii_rst_n_host;
//tsntag & bufid input from host_port
input          [2:0]   iv_pkt_type_ctrl;
input          [8:0]   iv_pkt_bufid_ctrl;
input                  i_mac_entry_hit_ctrl;
input          [3:0]   iv_pkt_inport_ctrl;
input                  i_pkt_bufid_wr_ctrl;
//receive pkt from PCB  
input       [133:0]    iv_pkt_data;
input                  i_pkt_data_wr;

output                 o_pkt_cnt_pulse;
output                 o_fifo_overflow_pulse;
// pkt_bufid to PCB in order to release pkt_bufid
output     [8:0]       ov_pkt_bufid;
output                 o_pkt_bufid_wr;
input                  i_pkt_bufid_ack; 
// read address to PCB in order to read pkt data       
output     [15:0]      ov_pkt_raddr;
output                 o_pkt_rd;
input                  i_pkt_raddr_ack;
// reset signal of local timer 
input                  i_timer_rst;  
// synchronized global time 
input      [47:0]      iv_syned_global_time;
// transmit pkt to phy     
output     [7:0]       ov_gmii_txd;
output                 o_gmii_tx_en;
output                 o_gmii_tx_er;
output                 o_gmii_tx_clk;

output     [3:0]       hoi_state;
output     [1:0]       bufid_state;
output     [2:0]       pkt_read_state;

wire       [13:0]      wv_descriptor_nqm2ntx;
wire                   w_descriptor_wr_nqm2ntx;
wire                   w_descriptor_ready_ntx2nqm;
control_queue_management control_queue_management_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_pkt_type_ctrl     (iv_pkt_type_ctrl    ),
.iv_pkt_bufid_ctrl    (iv_pkt_bufid_ctrl   ),
.i_mac_entry_hit_ctrl (i_mac_entry_hit_ctrl),
.iv_pkt_inport_ctrl   (iv_pkt_inport_ctrl  ),
.i_pkt_bufid_wr_ctrl  (i_pkt_bufid_wr_ctrl ),

.ov_descriptor        (wv_descriptor_nqm2ntx),
.o_descriptor_wr      (w_descriptor_wr_nqm2ntx),
.i_descriptor_ready   (w_descriptor_ready_ntx2nqm)
);
control_tx control_tx_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_host_gmii_tx_clk(i_host_gmii_tx_clk),
.i_gmii_rst_n_host(i_gmii_rst_n_host),

.iv_pkt_descriptor(wv_descriptor_nqm2ntx),
.i_pkt_descriptor_wr(w_descriptor_wr_nqm2ntx),
.o_pkt_descriptor_ready(w_descriptor_ready_ntx2nqm),

.ov_pkt_bufid(ov_pkt_bufid),
.o_pkt_bufid_wr(o_pkt_bufid_wr),
.i_pkt_bufid_ack(i_pkt_bufid_ack),  

.ov_pkt_raddr(ov_pkt_raddr),
.o_pkt_rd(o_pkt_rd),
.i_pkt_raddr_ack(i_pkt_raddr_ack),

.iv_pkt_data(iv_pkt_data),
.i_pkt_data_wr(i_pkt_data_wr),

.o_pkt_cnt_pulse(o_pkt_cnt_pulse),
.o_fifo_overflow_pulse(o_fifo_overflow_pulse),

.ov_gmii_txd(ov_gmii_txd),
.o_gmii_tx_en(o_gmii_tx_en),
.o_gmii_tx_er(o_gmii_tx_er),
.o_gmii_tx_clk(o_gmii_tx_clk),

.i_timer_rst(i_timer_rst), 
.iv_syned_global_time(iv_syned_global_time),

.hoi_state(hoi_state),
.bufid_state(bufid_state),
.pkt_read_state(pkt_read_state),

.ov_debug_ts_cnt(),
.ov_debug_cnt()   
);
endmodule
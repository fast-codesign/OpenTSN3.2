// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_transmit_process 
// Version: HTP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         transmit process of host.
//             -top module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_transmit_port
(
       i_clk,
       i_rst_n,

       i_host_gmii_tx_clk,
       i_gmii_rst_n_host,
       
       iv_syned_global_time,
            
       iv_tsntag_host,
       iv_pkt_type_host,
       iv_bufid_host,
       i_descriptor_wr_host,
       o_descriptor_ack_host,
       
       iv_tsntag_network,
       iv_pkt_type_network,
       iv_bufid_network,
       i_descriptor_wr_network,
       o_descriptor_ack_network,
       i_qbv_or_qch,
       
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
       
       o_ts_underflow_error_pulse,
       o_ts_overflow_error_pulse, 
       
       ov_gmii_txd,
       o_gmii_tx_en,
       //o_gmii_tx_er,
       //o_gmii_tx_clk,
       
       //i_timer_rst,
       iv_time_slot,
       i_time_slot_switch,
       
       iv_gate_ram_addr,         
       iv_gate_ram_wdata,        
       i_gate_ram_wr,            
       ov_gate_ram_rdata,        
       i_gate_ram_rd,       
       
       hos_state,
       hoi_state,
       bufid_state,
       pkt_read_state,
       tsm_state,
       ssm_state,  
       
       iv_submit_slot_table_wdata,
       i_submit_slot_table_wr,
       iv_submit_slot_table_addr,
       ov_submit_slot_table_rdata,
       i_submit_slot_table_rd,
       iv_submit_slot_table_period      
);

// I/O
// clk & rst
input                  i_clk;   
input                  i_rst_n;
// clock of gmii_tx
input                  i_host_gmii_tx_clk;
input                  i_gmii_rst_n_host;

input          [47:0]  iv_syned_global_time;
//tsntag & bufid input from host_port
input          [47:0]  iv_tsntag_host;
input          [2:0]   iv_pkt_type_host;
input          [8:0]   iv_bufid_host;
input                  i_descriptor_wr_host;
output                 o_descriptor_ack_host;
//tsntag & bufid input from hcp_port
input          [47:0]  iv_tsntag_network;
input          [2:0]   iv_pkt_type_network;
input          [8:0]   iv_bufid_network;
input                  i_descriptor_wr_network;
output                 o_descriptor_ack_network;

input                  i_qbv_or_qch;

input          [9:0]   iv_gate_ram_addr;         
input          [7:0]   iv_gate_ram_wdata;        
input                  i_gate_ram_wr;           
output         [7:0]   ov_gate_ram_rdata;        
input                  i_gate_ram_rd; 
                     
output         [9:0]   iv_time_slot;
input                  i_time_slot_switch;

//receive pkt from PCB  
input          [133:0] iv_pkt_data;
input                  i_pkt_data_wr;

output                 o_pkt_cnt_pulse;
output                 o_fifo_overflow_pulse;
// pkt_bufid to PCB in order to release pkt_bufid
output         [8:0]   ov_pkt_bufid;
output                 o_pkt_bufid_wr;
input                  i_pkt_bufid_ack; 
// read address to PCB in order to read pkt data       
output         [15:0]  ov_pkt_raddr;
output                 o_pkt_rd;
input                  i_pkt_raddr_ack;
// reset signal of local timer 
//input                  i_timer_rst;  
// transmit pkt to phy     
output         [8:0]   ov_gmii_txd;
output                 o_gmii_tx_en;
//output                 o_gmii_tx_er;
//output                 o_gmii_tx_clk;

output         [1:0]   hos_state;
output         [3:0]   hoi_state;
output         [1:0]   bufid_state;
output         [2:0]   pkt_read_state;
output         [2:0]   tsm_state;
output         [2:0]   ssm_state; 
               
input          [15:0]  iv_submit_slot_table_wdata;
input                  i_submit_slot_table_wr;
input          [9:0]   iv_submit_slot_table_addr;
output         [15:0]  ov_submit_slot_table_rdata;
input                  i_submit_slot_table_rd;
input          [10:0]  iv_submit_slot_table_period;
               
output                 o_ts_underflow_error_pulse;
output                 o_ts_overflow_error_pulse;
               
wire           [56:0]  wv_descriptor_mux2niq;
wire           [2:0]   wv_pkt_type_mux2niq;
wire                   w_descriptor_wr;
               
wire           [12:0]  wv_nts_descriptor_wdata;
wire                   w_nts_descriptor_wr;
               
wire           [31:0]  wv_ts_cnt; 
               
wire           [56:0]  wv_descriptor_nqm2ntx;
wire                   w_descriptor_wr_nqm2ntx;
wire                   w_descriptor_ready_ntx2nqm;
               
wire           [47:0]wv_dmac_fim2htx;
wire           [47:0]wv_TSNtag_nos2ntx;
               
wire           [8:0]wv_bufid_fim2htx;
wire                   w_lookup_table_match_flag_fim2htx;
wire                   w_descriptor_wr_fim2htx;
wire                   w_descriptor_ready_htx2fim;
               
//wire         
wire           [2:0]       wv_queue_id_niq2nos; 
wire                       w_queue_id_wr_niq2nos;
wire           [7:0]       wv_queue_empty_niq2nos;  
wire           [8:0]       wv_pkt_bufid_nos2ntx;    
wire                       w_pkt_bufid_wr_nos2ntx;
wire                       w_pkt_bufid_ack_ntx2nos;
               
wire           [56:0]      wv_queue_wdata_niq2nqm;
wire           [8:0]       wv_queue_waddr_niq2nqm;  
wire                       w_queue_wr_niq2nqm;       
                            
wire           [8:0]       wv_queue_raddr_nos2nqm;   
wire                       w_queue_rd_nos2nqm;
wire           [56:0]       wv_rd_queue_data_nqm2nos;
wire                       w_rd_queue_data_wr_nqm2nos;
               
wire           [1:0]       wv_gate_ctrl_vector_qgc2niq;
wire           [7:0]       wv_gate_ctrl_vector_qgc2nos;
               
wire           [2:0]       wv_schqueue_id_nos2niq;  
wire                       w_schqueue_id_wr_nos2niq;

descriptor_selecting descriptor_selecting_inst(

.i_clk                   (i_clk),
.i_rst_n                 (i_rst_n),
.iv_tsntag_host          (iv_tsntag_host),
.iv_pkt_type_host        (iv_pkt_type_host),
.iv_bufid_host           (iv_bufid_host),
.i_descriptor_wr_host    (i_descriptor_wr_host),
.o_descriptor_ack_host   (o_descriptor_ack_host),
.iv_tsntag_network       (iv_tsntag_network),
.iv_pkt_type_network     (iv_pkt_type_network),
.iv_bufid_network        (iv_bufid_network),
.i_descriptor_wr_network (i_descriptor_wr_network),
.o_descriptor_ack_network(o_descriptor_ack_network),
.ov_fifo_wdata           (wv_descriptor_mux2niq),
.ov_pkt_type             (wv_pkt_type_mux2niq),
.o_fifo_wr               (w_descriptor_wr)
);

network_input_queue network_input_queue_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                        
.iv_pkt_bufid           (wv_descriptor_mux2niq[8:0]),
.iv_TSNtag              (wv_descriptor_mux2niq[56:9]),
.iv_pkt_type            (wv_pkt_type_mux2niq),
.i_pkt_bufid_wr         (w_descriptor_wr),
 
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_gate_ctrl_vector    (wv_gate_ctrl_vector_qgc2niq),

.iv_schdule_id          (wv_schqueue_id_nos2niq),
.i_schdule_id_wr        (w_schqueue_id_wr_nos2niq), 
                       
.ov_queue_data          (wv_queue_wdata_niq2nqm),
.ov_queue_waddr         (wv_queue_waddr_niq2nqm),
.o_queue_wr             (w_queue_wr_niq2nqm),
                 
.ov_queue_id            (wv_queue_id_niq2nos),
.o_queue_id_wr          (w_queue_id_wr_niq2nos),
.ov_queue_empty         (wv_queue_empty_niq2nos)
);

queue_gate_control queue_gate_control_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),

.iv_ram_addr            (iv_gate_ram_addr),
.iv_ram_wdata           (iv_gate_ram_wdata),
.i_ram_wr               (i_gate_ram_wr),
.ov_ram_rdata           (ov_gate_ram_rdata),
.i_ram_rd               (i_gate_ram_rd),
 
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),

.ov_in_gate_ctrl_vector (wv_gate_ctrl_vector_qgc2niq),
.ov_out_gate_ctrl_vector(wv_gate_ctrl_vector_qgc2nos)
);

network_queue_manage network_queue_manage_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                        
.iv_queue_wdata         (wv_queue_wdata_niq2nqm),
.iv_queue_waddr         (wv_queue_waddr_niq2nqm),                   
.i_queue_wr             (w_queue_wr_niq2nqm),                     
                                                 
.iv_queue_raddr         (wv_queue_raddr_nos2nqm),                      
.i_queue_rd             (w_queue_rd_nos2nqm),
                        
.ov_queue_rdata         (wv_rd_queue_data_nqm2nos),
.o_queue_rdata_valid    (w_rd_queue_data_wr_nqm2nos)
);


network_output_schedule network_output_schedule_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                      
.iv_pkt_bufid           (wv_queue_waddr_niq2nqm),
.iv_pkt_next_bufid      (wv_queue_wdata_niq2nqm[8:0]),
.iv_tsntag              (wv_queue_wdata_niq2nqm[56:9]),
.iv_queue_id            (wv_queue_id_niq2nos),
.i_queue_id_wr          (w_queue_id_wr_niq2nos),
.iv_queue_empty         (wv_queue_empty_niq2nos),

.ov_schdule_id          (wv_schqueue_id_nos2niq),
.o_schdule_id_wr        (w_schqueue_id_wr_nos2niq),  
                       
.iv_gate_ctrl_vector    (wv_gate_ctrl_vector_qgc2nos),
                      
.ov_queue_raddr         (wv_queue_raddr_nos2nqm),
.o_queue_rd             (w_queue_rd_nos2nqm),
.iv_rd_queue_data       (wv_rd_queue_data_nqm2nos),
.i_rd_queue_data_wr     (w_rd_queue_data_wr_nqm2nos),
 
.ov_pkt_bufid           (wv_pkt_bufid_nos2ntx), 
.ov_TSNtag              (wv_TSNtag_nos2ntx),
.o_pkt_bufid_wr         (w_pkt_bufid_wr_nos2ntx),
                       
.i_pkt_bufid_ack        (w_descriptor_ready_ntx2nqm),

.ov_osc_state           (ov_osc_state)
);


network_tx network_tx_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),

.i_gmii_clk             (i_host_gmii_tx_clk),
.i_gmii_rst_n           (i_gmii_rst_n_host),

.iv_pkt_descriptor      ({wv_TSNtag_nos2ntx,wv_pkt_bufid_nos2ntx}),
.i_pkt_descriptor_wr    (w_pkt_bufid_wr_nos2ntx),
.o_pkt_descriptor_ready (w_descriptor_ready_ntx2nqm),

.ov_pkt_bufid           (ov_pkt_bufid),
.o_pkt_bufid_wr         (o_pkt_bufid_wr),
.i_pkt_bufid_ack        (i_pkt_bufid_ack),  

.ov_pkt_raddr           (ov_pkt_raddr),
.o_pkt_rd               (o_pkt_rd),
.i_pkt_raddr_ack        (i_pkt_raddr_ack),

.iv_pkt_data            (iv_pkt_data),
.i_pkt_data_wr          (i_pkt_data_wr),

.ov_prc_state          (),
.ov_opc_state          (),
.o_outpkt_pulse        (o_pkt_cnt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse),

.ov_gmii_txd            (ov_gmii_txd),
.o_gmii_tx_en           (o_gmii_tx_en),
.o_gmii_tx_er           (),
.o_gmii_tx_clk          ()
);

endmodule
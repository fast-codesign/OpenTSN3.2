// Copyright (C) 1953-2021 NUDT
// Verilog module name - packet_map_dispatch
// Version: V3.2.2.20210820
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         map traffic transmitted by user into traffic identificated by network.
//             - monitor whether TS packet is overflow, 
//             - generate descriptor of packet, 
//             - write packet to ram,
//             - write descriptor of TS packet to ram,
//             - transmit descriptor of not TS packet to FLT to look up table;
//             - top module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module packet_map_dispatch
(
       i_clk,
       i_rst_n,
       
       iv_data,
       i_data_wr,
       
       iv_bufid,
       i_bufid_wr,
       o_bufid_ack,
       
       ov_wdata,
       o_data_wr,
       ov_data_waddr,
       i_wdata_ack,
       
       o_pkt_cnt_pulse,
       o_pkt_discard_cnt_pulse,
       
       tom_state,
       descriptor_state,
       pkt_state,
       transmission_state, 
       
       ov_ts_descriptor,
       o_ts_descriptor_wr,
       ov_ts_descriptor_waddr,
       
       ov_nts_descriptor,
       o_nts_descriptor_wr,
       i_nts_descriptor_ack,
       
       iv_free_bufid_fifo_rdusedw,
       iv_map_req_threshold_value,
       iv_be_threshold_value,
       iv_rc_threshold_value,
       
       iv_fmt_ram_addr,
       i_fmt_ram_wr,
       iv_fmt_ram_wdata,
	   ov_fmt_ram_rdata,
	   i_fmt_ram_rd,
       
       ov_ip_tsntag,
       ov_pkt_type,
       ov_ip_bufid,
       o_ip_descriptor_wr,
       i_ip_descriptor_ack       
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input      [8:0]       iv_data;
input                  i_data_wr;
//TS traffic state
//input      [31:0]      iv_ts_cnt;
// bufid input
input      [8:0]       iv_bufid;
input                  i_bufid_wr;
output                 o_bufid_ack;
// pkt output
output    [133:0]      ov_wdata;
output                 o_data_wr;
output    [15:0]       ov_data_waddr;
input                  i_wdata_ack;

output                 o_pkt_cnt_pulse;
output     [1:0]       tom_state;
output     [2:0]       descriptor_state;
output     [2:0]       pkt_state;
output     [2:0]       transmission_state;
// descriptor of ts pkt output
output    [35:0]       ov_ts_descriptor;
output                 o_ts_descriptor_wr;
output    [4:0]        ov_ts_descriptor_waddr;
// descriptor of not ts pkt output
output    [45:0]       ov_nts_descriptor;
output                 o_nts_descriptor_wr;
input                  i_nts_descriptor_ack; 
//threshold of discard
input      [8:0]       iv_free_bufid_fifo_rdusedw;
input      [8:0]       iv_map_req_threshold_value;
input      [8:0]       iv_be_threshold_value;
input      [8:0]       iv_rc_threshold_value;
//map table
input      [4:0]       iv_fmt_ram_addr;
input                  i_fmt_ram_wr;
input      [151:0]     iv_fmt_ram_wdata;
output     [151:0]     ov_fmt_ram_rdata;
input                  i_fmt_ram_rd;

output                 o_pkt_discard_cnt_pulse;
//tsntag & bufid output 
output     [47:0]      ov_ip_tsntag;
output     [2:0]       ov_pkt_type;
output     [8:0]       ov_ip_bufid;
output                 o_ip_descriptor_wr;
input                  i_ip_descriptor_ack;

wire       [8:0]       wv_bufid_abm2trr;
wire                   w_bufid_empty_abm2trr;
wire                   w_get_new_bufid_req;

wire       [133:0]     wv_data1_trw2trr;
wire                   w_data1_write_flag_trw2trr;
wire       [133:0]     wv_data2_trw2trr;
wire                   w_data2_write_flag_trw2trr;

//read ram
wire                   w_fmt_ram_rd;
wire       [4:0]       wv_fmt_ram_raddr;
wire       [130:0]     wv_fmt_ram_rdata;
                       
//five tuple
wire       [103:0]     wv_5tuple_data_mke2lmt;
wire                   w_5tuple_data_wr_mke2lmt;
//dmac
wire       [47:0]      wv_dmac_mke2lmt;
wire       [8:0]       wv_bufid_mke2lmt;
wire                   w_tcp_or_udp_flag_mke2lmt;
//lmt-tpo
wire       [47:0]      wv_tsntag_lmt2tpo;
wire       [2:0]       wv_pkt_type_lmt2tpo;
wire       [8:0]       wv_bufid_lmt2tpo;
wire                   w_descriptor_wr_lmt2tpo;

wire       [130:0]     wv_ram_wdata;
wire       [130:0]     wv_ram_rdata;
assign wv_ram_wdata = {iv_fmt_ram_wdata[151:31], iv_fmt_ram_wdata[9:0]};
assign ov_fmt_ram_rdata = {wv_ram_rdata[130:27], wv_ram_rdata[26:10], 21'b0, wv_ram_rdata[9:0]};
wire       [8:0]       wv_data_bar2pwtmke;
wire                   w_data_wr_bar2pwtmke;
wire       [8:0]       wv_bufid_bar2pwtmke;

wire       [8:0]       wv_bufid_pwt2cbi;
buffer_address_receive buffer_address_receive_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(iv_data),
.i_data_wr(i_data_wr),

.i_bufid_wr(i_bufid_wr),
.iv_bufid(iv_bufid),

.ov_data(wv_data_bar2pwtmke),
.o_data_wr(w_data_wr_bar2pwtmke),
.ov_bufid(wv_bufid_bar2pwtmke)    
); 
pkt_width_transfer pkt_width_transfer_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(wv_data_bar2pwtmke),
.i_data_wr(w_data_wr_bar2pwtmke),
.iv_bufid(wv_bufid_bar2pwtmke),

.o_pkt_discard_cnt_pulse(o_pkt_discard_cnt_pulse),

.ov_data1(wv_data1_trw2trr),
.o_data1_write_flag(w_data1_write_flag_trw2trr),
.ov_data2(wv_data2_trw2trr),
.o_data2_write_flag(w_data2_write_flag_trw2trr),  
.ov_bufid(wv_bufid_pwt2cbi),
.pkt_state(pkt_state)
);  
centralized_buffer_interface centralized_buffer_interface_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data1(wv_data1_trw2trr),
.iv_data2(wv_data2_trw2trr),

.i_data1_write_flag(w_data1_write_flag_trw2trr),
.i_data2_write_flag(w_data2_write_flag_trw2trr),

.iv_bufid(wv_bufid_pwt2cbi),

.ov_wdata(ov_wdata),
.o_data_wr(o_data_wr),
.ov_data_waddr(ov_data_waddr),
.i_wdata_ack(i_wdata_ack),
.transmission_state(transmission_state),
.ov_debug_ts_out_cnt()
);
map_key_extract map_key_extract_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(wv_data_bar2pwtmke),
.i_data_wr(w_data_wr_bar2pwtmke),
.iv_bufid(wv_bufid_bar2pwtmke),

.ov_5tuple_data(wv_5tuple_data_mke2lmt),
.o_5tuple_data_wr(w_5tuple_data_wr_mke2lmt),

.ov_dmac(wv_dmac_mke2lmt),
.ov_bufid(wv_bufid_mke2lmt),
.o_tcp_or_udp_flag(w_tcp_or_udp_flag_mke2lmt)  
); 
lookup_map_table lookup_map_table_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_5tuple_data(wv_5tuple_data_mke2lmt),
.i_5tuple_data_wr(w_5tuple_data_wr_mke2lmt),

.iv_dmac(wv_dmac_mke2lmt),
.iv_bufid(wv_bufid_mke2lmt),
.i_tcp_or_udp_flag(w_tcp_or_udp_flag_mke2lmt),

.o_fmt_ram_rd(w_fmt_ram_rd),
.ov_fmt_ram_raddr(wv_fmt_ram_raddr),
.iv_fmt_ram_rdata(wv_fmt_ram_rdata),

//.ov_tsntag(ov_ip_tsntag),
//.ov_pkt_type(ov_pkt_type),
//.ov_bufid(ov_ip_bufid),
//.o_descriptor_wr(o_ip_descriptor_wr),
//.i_descriptor_ack(i_ip_descriptor_ack)

.ov_tsntag(wv_tsntag_lmt2tpo),
.ov_pkt_type(wv_pkt_type_lmt2tpo),
.ov_bufid(wv_bufid_lmt2tpo),
.o_descriptor_wr(w_descriptor_wr_lmt2tpo)
);

traffic_police traffic_police_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_tsntag(wv_tsntag_lmt2tpo),
.iv_pkt_type(wv_pkt_type_lmt2tpo),
.iv_bufid(wv_bufid_lmt2tpo),
.i_descriptor_wr(w_descriptor_wr_lmt2tpo),

.iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
.iv_rc_threshold_value(iv_rc_threshold_value),
.iv_be_threshold_value(iv_be_threshold_value),

.o_bufid_ack(o_bufid_ack),

.o_pkt_discard_pulse(),

.ov_tsntag(ov_ip_tsntag),
.ov_pkt_type(ov_pkt_type),
.ov_bufid(ov_ip_bufid),
.o_descriptor_wr(o_ip_descriptor_wr),
.i_descriptor_ack(i_ip_descriptor_ack)
);

ram_32_131 ram_32_131_inst(
.data_a    (wv_ram_wdata),    //  ram_input.datain_a
.data_b    (131'b0),    //           .datain_b
.address_a (iv_fmt_ram_addr), //           .address_a
.address_b (wv_fmt_ram_raddr), //           .address_b
.wren_a    (i_fmt_ram_wr),    //           .wren_a
.wren_b    (1'b0),    //           .wren_b
.clock     (i_clk),     //           .clock
.rden_a    (i_fmt_ram_rd),    //           .rden_a
.rden_b    (w_fmt_ram_rd),    //           .rden_b
.q_a       (wv_ram_rdata),       // ram_output.dataout_a
.q_b       (wv_fmt_ram_rdata)        //           .dataout_b
);  
endmodule
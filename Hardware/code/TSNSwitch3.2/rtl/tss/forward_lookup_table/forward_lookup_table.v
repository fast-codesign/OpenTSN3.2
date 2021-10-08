// Copyright (C) 1953-2021 NUDT
// Verilog module name - forward_lookup_table 
// Version: V3.2.0.20210722
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         use RAM to cahce the forward table
//         parse ctrl data,and compelet the configuration of the lookup table 
//         time division multiplexing for receive descriptor come from network port and host port
//         determine whether a table lookup is required
//         extract flow_id from descriptor,and complete the table
//         forward based on the result of the lookup table
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module forward_lookup_table
(
       i_clk,
       i_rst_n,
              
       iv_descriptor_p0,
       i_descriptor_wr_p0,
       o_descriptor_ack_p0,
       
       iv_descriptor_p1,
       i_descriptor_wr_p1,
       o_descriptor_ack_p1,
       
       iv_descriptor_p2,
       i_descriptor_wr_p2,
       o_descriptor_ack_p2,
       
       iv_descriptor_p3,
       i_descriptor_wr_p3,
       o_descriptor_ack_p3,
       
       iv_descriptor_p4,
       i_descriptor_wr_p4,
       o_descriptor_ack_p4,     

       ov_pkt_bufid_p0,
       ov_pkt_type_p0,
       o_pkt_bufid_wr_p0,
       
       ov_pkt_bufid_p1,
       ov_pkt_type_p1,
       o_pkt_bufid_wr_p1,
       
       ov_pkt_bufid_p2,
       ov_pkt_type_p2,
       o_pkt_bufid_wr_p2,
       
       ov_pkt_bufid_p3,
       ov_pkt_type_p3,
       o_pkt_bufid_wr_p3,
       
       ov_pkt_bufid_host   ,
       ov_pkt_type_host    ,
       o_mac_entry_hit_host,
       ov_pkt_inport_host  ,
       o_pkt_bufid_wr_host ,
		
       ov_pkt_bufid,
       o_pkt_bufid_wr,
       ov_pkt_bufid_cnt,
       
       ov_tdm_state,
       
       iv_flowidram_addr, 
       iv_flowidram_wdata,
       i_flowidram_wr,    
       ov_flowidram_rdata,
       i_flowidram_rd,

       iv_dmacram_addr, 
       iv_dmacram_wdata,
       i_dmacram_wr,    
       ov_dmacram_rdata,
       i_dmacram_rd   	   
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;
// descriptor from p0
input      [71:0]      iv_descriptor_p0;
input                  i_descriptor_wr_p0;
output                 o_descriptor_ack_p0;
// descriptor from p1      
input      [71:0]      iv_descriptor_p1;
input                  i_descriptor_wr_p1;
output                 o_descriptor_ack_p1;
// descriptor from p2      
input      [71:0]      iv_descriptor_p2;
input                  i_descriptor_wr_p2;
output                 o_descriptor_ack_p2;
// descriptor from p3      
input      [71:0]      iv_descriptor_p3;
input                  i_descriptor_wr_p3;
output                 o_descriptor_ack_p3;
// descriptor from p4      
input      [71:0]      iv_descriptor_p4;
input                  i_descriptor_wr_p4;
output                 o_descriptor_ack_p4;

// pkt_bufid and pkt_type to p0
output     [8:0]       ov_pkt_bufid_p0;
output     [2:0]       ov_pkt_type_p0;
output                 o_pkt_bufid_wr_p0;
// pkt_bufid and pkt_type to p1   
output     [8:0]       ov_pkt_bufid_p1;
output     [2:0]       ov_pkt_type_p1;
output                 o_pkt_bufid_wr_p1;
// pkt_bufid and pkt_type to p2    
output     [8:0]       ov_pkt_bufid_p2;
output     [2:0]       ov_pkt_type_p2;
output                 o_pkt_bufid_wr_p2;
// pkt_bufid and pkt_type to p3    
output     [8:0]       ov_pkt_bufid_p3;
output     [2:0]       ov_pkt_type_p3;
output                 o_pkt_bufid_wr_p3;
// pkt_bufid and pkt_type to p4    
output     [8:0]       ov_pkt_bufid_host   ;
output     [2:0]       ov_pkt_type_host    ;
output                 o_mac_entry_hit_host;
output     [3:0]       ov_pkt_inport_host  ;
output                 o_pkt_bufid_wr_host ;

//forward cnt to pkt_centralize_bufm_memory
output     [8:0]       ov_pkt_bufid;
output                 o_pkt_bufid_wr;
output     [3:0]       ov_pkt_bufid_cnt;

output     [3:0]       ov_tdm_state;

//lookup table RAM
input      [13:0]      iv_flowidram_addr;
input      [8:0]       iv_flowidram_wdata;
input                  i_flowidram_wr;    
output     [8:0]       ov_flowidram_rdata;
input                  i_flowidram_rd; 
//lookup table RAM
input      [4:0]       iv_dmacram_addr;
input      [56:0]      iv_dmacram_wdata;
input                  i_dmacram_wr;    
output     [56:0]      ov_dmacram_rdata;
input                  i_dmacram_rd; 
 

// time_division_multiplexing to lookup_table
wire      [71:0]       wv_descriptor_tdm2lut;
wire                   w_descriptor_wr_tdm2lut;
 
// LUT to forward
wire      [8:0]        wv_outport_lut2fw;
wire                   w_outport_wr_lut2fw;
wire      [8:0]        wv_pkt_bufid_lut2fw;
wire      [2:0]        wv_pkt_type_lut2fw;
wire      [3:0]        wv_inport_lut2fw;
wire      [4:0]        wv_submit_addr_lut2fw;
wire                   w_pkt_bufid_wr_lut2fw;
// RAM form/to lookup_table/forward
wire      [8:0]        wv_ram_rdata_b;
wire      [13:0]       wv_ram_raddr_b;
wire                   w_ram_rd_b;

wire      [71:0]       wv_descriptor_p0;           
wire                   w_descriptor_wr_p0;         
wire                   w_descriptor_ack_p0;        
                        
wire      [71:0]       wv_descriptor_p1;           
wire                   w_descriptor_wr_p1;         
wire                   w_descriptor_ack_p1;        
                       
wire      [71:0]       wv_descriptor_p2;           
wire                   w_descriptor_wr_p2;         
wire                   w_descriptor_ack_p2;        

wire      [71:0]       wv_descriptor_p3;           
wire                   w_descriptor_wr_p3;         
wire                   w_descriptor_ack_p3;        

wire      [71:0]       wv_descriptor_p4;           
wire                   w_descriptor_wr_p4;         
wire                   w_descriptor_ack_p4;        

wire      [45:0]       wv_tsn_descriptor_dtd2flu;
wire                   w_tsn_descriptor_wr_dtd2flu;
                      
wire      [60:0]       wv_standard_descriptor_dtd2dlu;
wire                   w_standard_descriptor_wr_dtd2dlu;

wire                   w_fifo_rd_dlu2fifo;
wire      [60:0]       wv_fifo_rdata_fifo2dlu;
wire                   w_fifo_empty_fifo2dlu;

wire                   w_mac_ram_rd_dlu2ram;
wire      [4:0]        wv_mac_ram_raddr_dlu2ram;
wire      [56:0]       wv_mac_ram_rdata_ram2dlu;
                       
wire      [8:0]        wv_outport_dlu2spa   ;
wire                   w_entry_hit_dlu2spa  ;
wire      [2:0]        wv_pkt_type_dlu2spa  ;
wire      [3:0]        wv_pkt_inport_dlu2spa;
wire      [8:0]        wv_pkt_bufid_dlu2spa ;
wire                   w_action_req_dlu2spa ;
wire                   w_action_ack_spa2dlu ;

wire [8:0]       wv_pkt_bufid_p0_spa2acs     ;
wire [2:0]       wv_pkt_type_p0_spa2acs      ;
wire             w_pkt_bufid_req_p0_spa2acs  ;
wire             w_pkt_bufid_ack_p0_acs2spa  ;
wire [8:0]       wv_pkt_bufid_p1_spa2acs     ;
wire [2:0]       wv_pkt_type_p1_spa2acs      ;
wire             w_pkt_bufid_req_p1_spa2acs  ;
wire             w_pkt_bufid_ack_p1_acs2spa  ; 
wire [8:0]       wv_pkt_bufid_p2_spa2acs     ;
wire [2:0]       wv_pkt_type_p2_spa2acs      ;
wire             w_pkt_bufid_req_p2_spa2acs  ;
wire             w_pkt_bufid_ack_p2_acs2spa  ; 
wire [8:0]       wv_pkt_bufid_p3_spa2acs     ;
wire [2:0]       wv_pkt_type_p3_spa2acs      ;
wire             w_pkt_bufid_req_p3_spa2acs  ;
wire             w_pkt_bufid_ack_p3_acs2spa  ; 
wire [8:0]       wv_pkt_bufid_p4_spa2acs     ;
wire [2:0]       wv_pkt_type_p4_spa2acs      ;
wire             w_pkt_bufid_req_p4_spa2acs  ;
wire             w_pkt_bufid_ack_p4_acs2spa  ;
wire [8:0]       wv_pkt_bufid_p5_spa2acs     ;
wire [2:0]       wv_pkt_type_p5_spa2acs      ;
wire             w_pkt_bufid_req_p5_spa2acs  ;
wire             w_pkt_bufid_ack_p5_acs2spa  ;  
wire [8:0]       wv_pkt_bufid_p6_spa2acs     ;
wire [2:0]       wv_pkt_type_p6_spa2acs      ;
wire             w_pkt_bufid_req_p6_spa2acs  ;
wire             w_pkt_bufid_ack_p6_acs2spa  ;  
wire [8:0]       wv_pkt_bufid_p7_spa2acs     ;
wire [2:0]       wv_pkt_type_p7_spa2acs      ;
wire             w_pkt_bufid_req_p7_spa2acs  ;
wire             w_pkt_bufid_ack_p7_acs2spa  ;    
wire [8:0]       wv_pkt_bufid_host_spa2acs   ;
wire [2:0]       wv_pkt_type_host_spa2acs    ;
wire             w_mac_entry_hit_host_spa2acs;
wire [3:0]       wv_pkt_inport_host_spa2acs  ;
wire             w_pkt_bufid_req_host_spa2acs;
wire             w_pkt_bufid_ack_host_acs2spa;
wire [8:0]       wv_pkt_bufid_spa2acs        ;
wire             w_pkt_bufid_req_spa2acs     ;
wire             w_pkt_bufid_ack_acs2spa     ;
wire [3:0]       wv_pkt_bufid_cnt_spa2acs    ;

wire [8:0]       wv_pkt_bufid_p0_tpa2acs     ;
wire [2:0]       wv_pkt_type_p0_tpa2acs      ;
wire             w_pkt_bufid_wr_p0_tpa2acs   ;

wire [8:0]       wv_pkt_bufid_p1_tpa2acs     ;
wire [2:0]       wv_pkt_type_p1_tpa2acs      ;
wire             w_pkt_bufid_wr_p1_tpa2acs   ;

wire [8:0]       wv_pkt_bufid_p2_tpa2acs     ;
wire [2:0]       wv_pkt_type_p2_tpa2acs      ;
wire             w_pkt_bufid_wr_p2_tpa2acs   ;
  
wire [8:0]       wv_pkt_bufid_p3_tpa2acs     ;
wire [2:0]       wv_pkt_type_p3_tpa2acs      ;
wire             w_pkt_bufid_wr_p3_tpa2acs   ; 
   
wire [8:0]       wv_pkt_bufid_host_tpa2acs   ;
wire [2:0]       wv_pkt_type_host_tpa2acs    ;
wire [3:0]       wv_pkt_inport_host_tpa2acs  ;
wire             w_pkt_bufid_wr_host_tpa2acs ;

wire [8:0]       wv_pkt_bufid_tpa2acs        ;
wire             w_pkt_bufid_wr_tpa2acs      ;
wire [3:0]       wv_pkt_bufid_cnt_tpa2acs    ;
descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p0_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p0),
.i_descriptor_wr                (i_descriptor_wr_p0),
.o_descriptor_ack               (o_descriptor_ack_p0),
                                
.ov_descriptor                  (wv_descriptor_p0),
.o_descriptor_wr                (w_descriptor_wr_p0),
.i_descriptor_ack               (w_descriptor_ack_p0)
);
                                
descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p1_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p1),
.i_descriptor_wr                (i_descriptor_wr_p1),
.o_descriptor_ack               (o_descriptor_ack_p1),
                                
.ov_descriptor                  (wv_descriptor_p1),
.o_descriptor_wr                (w_descriptor_wr_p1),
.i_descriptor_ack               (w_descriptor_ack_p1)
);

descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p2_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p2),
.i_descriptor_wr                (i_descriptor_wr_p2),
.o_descriptor_ack               (o_descriptor_ack_p2),
                                
.ov_descriptor                  (wv_descriptor_p2),
.o_descriptor_wr                (w_descriptor_wr_p2),
.i_descriptor_ack               (w_descriptor_ack_p2)
);

descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p3_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p3),
.i_descriptor_wr                (i_descriptor_wr_p3),
.o_descriptor_ack               (o_descriptor_ack_p3),
                                
.ov_descriptor                  (wv_descriptor_p3),
.o_descriptor_wr                (w_descriptor_wr_p3),
.i_descriptor_ack               (w_descriptor_ack_p3)
);

descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p4_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p4),
.i_descriptor_wr                (i_descriptor_wr_p4),
.o_descriptor_ack               (o_descriptor_ack_p4),
                                
.ov_descriptor                  (wv_descriptor_p4),
.o_descriptor_wr                (w_descriptor_wr_p4),
.i_descriptor_ack               (w_descriptor_ack_p4)
);

time_division_multiplexing time_division_multiplexing_inst(
.i_clk                          (i_clk                      ),
.i_rst_n                        (i_rst_n                    ),
                                                           
.iv_descriptor_p0               (wv_descriptor_p0           ),
.i_descriptor_wr_p0             (w_descriptor_wr_p0         ),
.o_descriptor_ack_p0            (w_descriptor_ack_p0        ),
                                                         
.iv_descriptor_p1               (wv_descriptor_p1           ),
.i_descriptor_wr_p1             (w_descriptor_wr_p1         ),
.o_descriptor_ack_p1            (w_descriptor_ack_p1        ),
                                                        
.iv_descriptor_p2               (wv_descriptor_p2           ),
.i_descriptor_wr_p2             (w_descriptor_wr_p2         ),
.o_descriptor_ack_p2            (w_descriptor_ack_p2        ),
                                
.iv_descriptor_p3               (wv_descriptor_p3           ),
.i_descriptor_wr_p3             (w_descriptor_wr_p3         ),
.o_descriptor_ack_p3            (w_descriptor_ack_p3        ),
                                
.iv_descriptor_p4               (wv_descriptor_p4           ),
.i_descriptor_wr_p4             (w_descriptor_wr_p4         ),
.o_descriptor_ack_p4            (w_descriptor_ack_p4        ),                               

.ov_tdm_state                   (ov_tdm_state               ),

.ov_descriptor                  (wv_descriptor_tdm2lut      ),
.o_descriptor_wr                (w_descriptor_wr_tdm2lut    )
);

dmac_tsntag_distinguish dmac_tsntag_distinguish_inst(
.i_clk                     (i_clk),
.i_rst_n                   (i_rst_n),

.iv_descriptor             (wv_descriptor_tdm2lut),
.i_descriptor_wr           (w_descriptor_wr_tdm2lut),

.ov_tsn_descriptor         (wv_tsn_descriptor_dtd2flu),
.o_tsn_descriptor_wr       (w_tsn_descriptor_wr_dtd2flu),

.ov_standard_descriptor    (wv_standard_descriptor_dtd2dlu),
.o_standard_descriptor_wr  (w_standard_descriptor_wr_dtd2dlu)
);

flowid_lookup flowid_lookup_inst(                           
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                               
.iv_descriptor                  (wv_tsn_descriptor_dtd2flu),
.i_descriptor_wr                (w_tsn_descriptor_wr_dtd2flu),
                               
.ov_ram_raddr                   (wv_ram_raddr_b),
.o_ram_rd                       (w_ram_rd_b),
                               
.ov_outport                     (wv_outport_lut2fw),
.o_outport_wr                   (w_outport_wr_lut2fw),
.ov_pkt_bufid                   (wv_pkt_bufid_lut2fw),
.ov_pkt_type                    (wv_pkt_type_lut2fw),
.ov_submit_addr                 (wv_submit_addr_lut2fw),
.ov_inport                      (wv_inport_lut2fw),            
.o_pkt_bufid_wr                 (w_pkt_bufid_wr_lut2fw)
);

tsn_packet_action tsn_packet_action_inst(
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                              
.iv_outport                     (wv_outport_lut2fw),
.i_outport_wr                   (w_outport_wr_lut2fw),
.iv_pkt_bufid                   (wv_pkt_bufid_lut2fw),
.iv_pkt_type                    (wv_pkt_type_lut2fw),
.iv_submit_addr                 (wv_submit_addr_lut2fw),
.iv_inport                      (wv_inport_lut2fw),                 
.i_pkt_bufid_wr                 (w_pkt_bufid_wr_lut2fw),
                              
.ov_pkt_bufid_p0                (wv_pkt_bufid_p0_tpa2acs     ),
.ov_pkt_type_p0                 (wv_pkt_type_p0_tpa2acs      ),
.o_pkt_bufid_wr_p0              (w_pkt_bufid_wr_p0_tpa2acs   ), 
                                 
.ov_pkt_bufid_p1                (wv_pkt_bufid_p1_tpa2acs     ),
.ov_pkt_type_p1                 (wv_pkt_type_p1_tpa2acs      ),
.o_pkt_bufid_wr_p1              (w_pkt_bufid_wr_p1_tpa2acs   ),
                                 
.ov_pkt_bufid_p2                (wv_pkt_bufid_p2_tpa2acs     ),
.ov_pkt_type_p2                 (wv_pkt_type_p2_tpa2acs      ),
.o_pkt_bufid_wr_p2              (w_pkt_bufid_wr_p2_tpa2acs   ),
                                 
.ov_pkt_bufid_p3                (wv_pkt_bufid_p3_tpa2acs     ),
.ov_pkt_type_p3                 (wv_pkt_type_p3_tpa2acs      ),
.o_pkt_bufid_wr_p3              (w_pkt_bufid_wr_p3_tpa2acs   ),
                                 
.ov_pkt_bufid_host              (wv_pkt_bufid_host_tpa2acs   ), 
.ov_pkt_type_host               (wv_pkt_type_host_tpa2acs    ),
.ov_submit_addr_host            ()                            ,
.ov_inport_host                 (wv_pkt_inport_host_tpa2acs  ),
.o_pkt_bufid_wr_host            (w_pkt_bufid_wr_host_tpa2acs ),
                                   
.iv_ram_rdata                   (wv_ram_rdata_b              ),
                                 
.ov_pkt_bufid                   (wv_pkt_bufid_tpa2acs        ),
.o_pkt_bufid_wr                 (w_pkt_bufid_wr_tpa2acs      ),
.ov_pkt_bufid_cnt               (wv_pkt_bufid_cnt_tpa2acs    )
);

fifo_w61d32 fifo_w61d32_inst(
    .aclr(!i_rst_n),                   //Reset the all signal
    .data(wv_standard_descriptor_dtd2dlu),    //The Inport of data 
    .rdreq(w_fifo_rd_dlu2fifo),       //active-high
    .clock(i_clk),                       //ASYNC WriteClk(), SYNC use wrclk
    .wrreq(w_standard_descriptor_wr_dtd2dlu),       //active-high
    .q(wv_fifo_rdata_fifo2dlu),       //The output of data
    .full(),              //Write domain full 
    .empty(w_fifo_empty_fifo2dlu),                        //Write domain empty
    .usedw()                         //Read-usedword
);

dmac_lookup dmac_lookup_inst(
.i_clk             (i_clk),
.i_rst_n           (i_rst_n),

.iv_fifo_rdata     (wv_fifo_rdata_fifo2dlu  ),
.i_fifo_empty      (w_fifo_empty_fifo2dlu   ),
.o_fifo_rd         (w_fifo_rd_dlu2fifo      ),

.o_mac_ram_rd      (w_mac_ram_rd_dlu2ram    ),
.ov_mac_ram_raddr  (wv_mac_ram_raddr_dlu2ram),
.iv_mac_ram_rdata  (wv_mac_ram_rdata_ram2dlu),

.ov_outport        (wv_outport_dlu2spa   ),
.o_entry_hit       (w_entry_hit_dlu2spa  ),
.ov_pkt_type       (wv_pkt_type_dlu2spa  ),
.ov_pkt_inport     (wv_pkt_inport_dlu2spa),
.ov_pkt_bufid      (wv_pkt_bufid_dlu2spa ),
.o_action_req      (w_action_req_dlu2spa ),
.i_action_ack      (w_action_ack_spa2dlu )
);

standard_packet_action standard_packet_action_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),

.iv_outport             (wv_outport_dlu2spa   ),
.i_mac_entry_hit        (w_entry_hit_dlu2spa  ),
.iv_pkt_bufid           (wv_pkt_bufid_dlu2spa ),
.iv_pkt_type            (wv_pkt_type_dlu2spa  ),
.iv_pkt_inport          (wv_pkt_inport_dlu2spa),
.i_action_req           (w_action_req_dlu2spa ),
.o_action_ack           (w_action_ack_spa2dlu ),

.ov_pkt_bufid_p0        (wv_pkt_bufid_p0_spa2acs     ),
.ov_pkt_type_p0         (wv_pkt_type_p0_spa2acs      ),
.o_pkt_bufid_req_p0     (w_pkt_bufid_req_p0_spa2acs  ),
.i_pkt_bufid_ack_p0     (w_pkt_bufid_ack_p0_acs2spa  ),

.ov_pkt_bufid_p1        (wv_pkt_bufid_p1_spa2acs     ),
.ov_pkt_type_p1         (wv_pkt_type_p1_spa2acs      ),
.o_pkt_bufid_req_p1     (w_pkt_bufid_req_p1_spa2acs  ),
.i_pkt_bufid_ack_p1     (w_pkt_bufid_ack_p1_acs2spa  ),

.ov_pkt_bufid_p2        (wv_pkt_bufid_p2_spa2acs     ),
.ov_pkt_type_p2         (wv_pkt_type_p2_spa2acs      ),
.o_pkt_bufid_req_p2     (w_pkt_bufid_req_p2_spa2acs  ),
.i_pkt_bufid_ack_p2     (w_pkt_bufid_ack_p2_acs2spa  ),

.ov_pkt_bufid_p3        (wv_pkt_bufid_p3_spa2acs     ),
.ov_pkt_type_p3         (wv_pkt_type_p3_spa2acs      ),
.o_pkt_bufid_req_p3     (w_pkt_bufid_req_p3_spa2acs  ),
.i_pkt_bufid_ack_p3     (w_pkt_bufid_ack_p3_acs2spa  ),

.ov_pkt_bufid_p4        (wv_pkt_bufid_p4_spa2acs     ),
.ov_pkt_type_p4         (wv_pkt_type_p4_spa2acs      ),
.o_pkt_bufid_req_p4     (w_pkt_bufid_req_p4_spa2acs  ),
.i_pkt_bufid_ack_p4     (w_pkt_bufid_ack_p4_acs2spa  ),

.ov_pkt_bufid_p5        (wv_pkt_bufid_p5_spa2acs     ),
.ov_pkt_type_p5         (wv_pkt_type_p5_spa2acs      ),
.o_pkt_bufid_req_p5     (w_pkt_bufid_req_p5_spa2acs  ),
.i_pkt_bufid_ack_p5     (w_pkt_bufid_ack_p5_acs2spa  ),

.ov_pkt_bufid_p6        (wv_pkt_bufid_p6_spa2acs     ),
.ov_pkt_type_p6         (wv_pkt_type_p6_spa2acs      ),
.o_pkt_bufid_req_p6     (w_pkt_bufid_req_p6_spa2acs  ),
.i_pkt_bufid_ack_p6     (w_pkt_bufid_ack_p6_acs2spa  ),

.ov_pkt_bufid_p7        (wv_pkt_bufid_p7_spa2acs     ),
.ov_pkt_type_p7         (wv_pkt_type_p7_spa2acs      ),
.o_pkt_bufid_req_p7     (w_pkt_bufid_req_p7_spa2acs  ),
.i_pkt_bufid_ack_p7     (w_pkt_bufid_ack_p7_acs2spa  ),

.ov_pkt_bufid_host      (wv_pkt_bufid_host_spa2acs   ),
.ov_pkt_type_host       (wv_pkt_type_host_spa2acs    ),
.ov_pkt_inport_host     (wv_pkt_inport_host_spa2acs  ),
.o_mac_entry_hit_host   (w_mac_entry_hit_host_spa2acs),
.o_pkt_bufid_req_host   (w_pkt_bufid_req_host_spa2acs),
.i_pkt_bufid_ack_host   (w_pkt_bufid_ack_host_acs2spa),

.ov_pkt_bufid           (wv_pkt_bufid_spa2acs        ),
.o_pkt_bufid_req        (w_pkt_bufid_req_spa2acs     ),
.i_pkt_bufid_ack        (w_pkt_bufid_ack_acs2spa     ),
.ov_pkt_bufid_cnt       (wv_pkt_bufid_cnt_spa2acs    )
);
action_selecting action_selecting_inst(
.i_clk                    (i_clk),
.i_rst_n                  (i_rst_n),
//from tpa                 
.iv_pkt_bufid_p0_tpa      (wv_pkt_bufid_p0_tpa2acs     ),
.iv_pkt_type_p0_tpa       (wv_pkt_type_p0_tpa2acs      ),
.i_pkt_bufid_wr_p0_tpa    (w_pkt_bufid_wr_p0_tpa2acs   ),
                           
.iv_pkt_bufid_p1_tpa      (wv_pkt_bufid_p1_tpa2acs     ),
.iv_pkt_type_p1_tpa       (wv_pkt_type_p1_tpa2acs      ),
.i_pkt_bufid_wr_p1_tpa    (w_pkt_bufid_wr_p1_tpa2acs   ),
                           
.iv_pkt_bufid_p2_tpa      (wv_pkt_bufid_p2_tpa2acs     ),
.iv_pkt_type_p2_tpa       (wv_pkt_type_p2_tpa2acs      ),
.i_pkt_bufid_wr_p2_tpa    (w_pkt_bufid_wr_p2_tpa2acs   ),
                           
.iv_pkt_bufid_p3_tpa      (wv_pkt_bufid_p3_tpa2acs     ),
.iv_pkt_type_p3_tpa       (wv_pkt_type_p3_tpa2acs      ),
.i_pkt_bufid_wr_p3_tpa    (w_pkt_bufid_wr_p3_tpa2acs   ),
                           
.iv_pkt_bufid_p4_tpa      (9'b0),
.iv_pkt_type_p4_tpa       (3'b0),
.i_pkt_bufid_wr_p4_tpa    (1'b0),
                           
.iv_pkt_bufid_p5_tpa      (9'b0),
.iv_pkt_type_p5_tpa       (3'b0),
.i_pkt_bufid_wr_p5_tpa    (1'b0),
             
.iv_pkt_bufid_p6_tpa      (9'b0),
.iv_pkt_type_p6_tpa       (3'b0),
.i_pkt_bufid_wr_p6_tpa    (1'b0),
              
.iv_pkt_bufid_p7_tpa      (9'b0),
.iv_pkt_type_p7_tpa       (3'b0),
.i_pkt_bufid_wr_p7_tpa    (1'b0),
               
.iv_pkt_bufid_host_tpa    (wv_pkt_bufid_host_tpa2acs   ),
.iv_pkt_type_host_tpa     (wv_pkt_type_host_tpa2acs    ),
.iv_pkt_inport_host_tpa   (wv_pkt_inport_host_tpa2acs  ),
.i_pkt_bufid_wr_host_tpa  (w_pkt_bufid_wr_host_tpa2acs ),
                           
.iv_pkt_bufid_tpa         (wv_pkt_bufid_tpa2acs        ),
.i_pkt_bufid_wr_tpa       (w_pkt_bufid_wr_tpa2acs      ),
.iv_pkt_bufid_cnt_tpa     (wv_pkt_bufid_cnt_tpa2acs    ),
//from spa     
.iv_pkt_bufid_p0_spa      (wv_pkt_bufid_p0_spa2acs     ),
.iv_pkt_type_p0_spa       (wv_pkt_type_p0_spa2acs      ),
.i_pkt_bufid_req_p0_spa   (w_pkt_bufid_req_p0_spa2acs  ),
.o_pkt_bufid_ack_p0_spa   (w_pkt_bufid_ack_p0_acs2spa  ),
                           
.iv_pkt_bufid_p1_spa      (wv_pkt_bufid_p1_spa2acs     ),
.iv_pkt_type_p1_spa       (wv_pkt_type_p1_spa2acs      ),
.i_pkt_bufid_req_p1_spa   (w_pkt_bufid_req_p1_spa2acs  ),
.o_pkt_bufid_ack_p1_spa   (w_pkt_bufid_ack_p1_acs2spa  ),
                           
.iv_pkt_bufid_p2_spa      (wv_pkt_bufid_p2_spa2acs     ),
.iv_pkt_type_p2_spa       (wv_pkt_type_p2_spa2acs      ),
.i_pkt_bufid_req_p2_spa   (w_pkt_bufid_req_p2_spa2acs  ),
.o_pkt_bufid_ack_p2_spa   (w_pkt_bufid_ack_p2_acs2spa  ),
                           
.iv_pkt_bufid_p3_spa      (wv_pkt_bufid_p3_spa2acs     ),
.iv_pkt_type_p3_spa       (wv_pkt_type_p3_spa2acs      ),
.i_pkt_bufid_req_p3_spa   (w_pkt_bufid_req_p3_spa2acs  ),
.o_pkt_bufid_ack_p3_spa   (w_pkt_bufid_ack_p3_acs2spa  ),
                           
.iv_pkt_bufid_p4_spa      (wv_pkt_bufid_p4_spa2acs     ),
.iv_pkt_type_p4_spa       (wv_pkt_type_p4_spa2acs      ),
.i_pkt_bufid_req_p4_spa   (w_pkt_bufid_req_p4_spa2acs  ),
.o_pkt_bufid_ack_p4_spa   (w_pkt_bufid_ack_p4_acs2spa  ),
                           
.iv_pkt_bufid_p5_spa      (wv_pkt_bufid_p5_spa2acs     ),
.iv_pkt_type_p5_spa       (wv_pkt_type_p5_spa2acs      ),
.i_pkt_bufid_req_p5_spa   (w_pkt_bufid_req_p5_spa2acs  ),
.o_pkt_bufid_ack_p5_spa   (w_pkt_bufid_ack_p5_acs2spa  ),
                           
.iv_pkt_bufid_p6_spa      (wv_pkt_bufid_p6_spa2acs     ),
.iv_pkt_type_p6_spa       (wv_pkt_type_p6_spa2acs      ),
.i_pkt_bufid_req_p6_spa   (w_pkt_bufid_req_p6_spa2acs  ),
.o_pkt_bufid_ack_p6_spa   (w_pkt_bufid_ack_p6_acs2spa  ),
                           
.iv_pkt_bufid_p7_spa      (wv_pkt_bufid_p7_spa2acs     ),
.iv_pkt_type_p7_spa       (wv_pkt_type_p7_spa2acs      ),
.i_pkt_bufid_req_p7_spa   (w_pkt_bufid_req_p7_spa2acs  ),
.o_pkt_bufid_ack_p7_spa   (w_pkt_bufid_ack_p7_acs2spa  ),
                           
.iv_pkt_bufid_host_spa    (wv_pkt_bufid_host_spa2acs   ),
.iv_pkt_type_host_spa     (wv_pkt_type_host_spa2acs    ),
.i_mac_entry_hit_spa      (w_mac_entry_hit_host_spa2acs),
.iv_pkt_inport_host_spa   (wv_pkt_inport_host_spa2acs  ),
.i_pkt_bufid_req_host_spa (w_pkt_bufid_req_host_spa2acs),
.o_pkt_bufid_ack_host_spa (w_pkt_bufid_ack_host_acs2spa),
                           
.iv_pkt_bufid_spa         (wv_pkt_bufid_spa2acs        ),
.i_pkt_bufid_req_spa      (w_pkt_bufid_req_spa2acs     ),
.o_pkt_bufid_ack_spa	  (w_pkt_bufid_ack_acs2spa     ), 
.iv_pkt_bufid_cnt_spa     (wv_pkt_bufid_cnt_spa2acs    ),
//output             
.ov_pkt_bufid_p0          (ov_pkt_bufid_p0     ),
.ov_pkt_type_p0           (ov_pkt_type_p0      ),
.o_pkt_bufid_wr_p0        (o_pkt_bufid_wr_p0   ),
                                              
.ov_pkt_bufid_p1          (ov_pkt_bufid_p1     ),
.ov_pkt_type_p1           (ov_pkt_type_p1      ),
.o_pkt_bufid_wr_p1        (o_pkt_bufid_wr_p1   ),
                           
.ov_pkt_bufid_p2          (ov_pkt_bufid_p2     ),
.ov_pkt_type_p2           (ov_pkt_type_p2      ),
.o_pkt_bufid_wr_p2        (o_pkt_bufid_wr_p2   ),
                           
.ov_pkt_bufid_p3          (ov_pkt_bufid_p3     ),
.ov_pkt_type_p3           (ov_pkt_type_p3      ),
.o_pkt_bufid_wr_p3        (o_pkt_bufid_wr_p3   ),
                           
.ov_pkt_bufid_p4          (),
.ov_pkt_type_p4           (),
.o_pkt_bufid_wr_p4        (),
                           
.ov_pkt_bufid_p5          (),
.ov_pkt_type_p5           (),
.o_pkt_bufid_wr_p5        (),
                           
.ov_pkt_bufid_p6          (),
.ov_pkt_type_p6           (),
.o_pkt_bufid_wr_p6        (),
               
.ov_pkt_bufid_p7          (),
.ov_pkt_type_p7           (),
.o_pkt_bufid_wr_p7        (),
               
.ov_pkt_bufid_host        (ov_pkt_bufid_host   ),
.ov_pkt_type_host         (ov_pkt_type_host    ),
.o_mac_entry_hit_host     (o_mac_entry_hit_host),
.ov_pkt_inport_host       (ov_pkt_inport_host  ),
.o_pkt_bufid_wr_host      (o_pkt_bufid_wr_host ),
               
.ov_pkt_bufid             (ov_pkt_bufid        ),
.o_pkt_bufid_wr           (o_pkt_bufid_wr      ),
.ov_pkt_bufid_cnt 	      (ov_pkt_bufid_cnt    )
);

suhddpsram32x57 suhddpsram32x57_inst(
.aclr                          (!i_rst_n),
                              
.address_a                     (iv_dmacram_addr),
.address_b                     (wv_mac_ram_raddr_dlu2ram),
                             
.clock                         (i_clk),
                             
.data_a                        (iv_dmacram_wdata),
.data_b                        (57'h0),
                              
.rden_a                        (i_dmacram_rd),
.rden_b                        (w_mac_ram_rd_dlu2ram),
                             
.wren_a                        (i_dmacram_wr),
.wren_b                        (1'b0),
                              
.q_a                           (ov_dmacram_rdata),
.q_b                           (wv_mac_ram_rdata_ram2dlu)
);
suhddpsram16384x9_s suhddpsram16384x9_s_inst(
.aclr                          (!i_rst_n),
                              
.address_a                     (iv_flowidram_addr),
.address_b                     (wv_ram_raddr_b),
                             
.clock                         (i_clk),
                             
.data_a                        (iv_flowidram_wdata),
.data_b                        (9'h0),
                              
.rden_a                        (i_flowidram_rd),
.rden_b                        (w_ram_rd_b),
                             
.wren_a                        (i_flowidram_wr),
.wren_b                        (1'b0),
                              
.q_a                           (ov_flowidram_rdata),
.q_b                           (wv_ram_rdata_b)
);
endmodule
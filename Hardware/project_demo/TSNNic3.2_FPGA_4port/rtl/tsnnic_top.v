// Copyright (C) 1953-2021 NUDT
// Verilog module name - tsnnic_top
// Version: V3.2.1.20210818
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         the internet clock field of the chip is switched to the external PHY clock field
//         send pkt data from gmii
////////////////////////////////////////////////////////////////////////////
module tsnnic_top (
       i_clk,
	   
	   i_hard_rst_n,
	   i_button_rst_n,
	   i_et_resetc_rst_n,  

	   ov_gmii_txd_p0,
	   o_gmii_tx_en_p0,
	   o_gmii_tx_er_p0,
	   o_gmii_tx_clk_p0,
       
	   i_gmii_rxclk_p1,
	   i_gmii_dv_p1,
	   iv_gmii_rxd_p1,
	   i_gmii_er_p1,            
	   ov_gmii_txd_p1,
	   o_gmii_tx_en_p1,
	   o_gmii_tx_er_p1,
	   o_gmii_tx_clk_p1,
       
	   ov_gmii_txd_p2,
	   o_gmii_tx_en_p2,
	   o_gmii_tx_er_p2,
	   o_gmii_tx_clk_p2,

	   //hrp
	   i_gmii_rxclk_host,
	   i_gmii_dv_host,
	   iv_gmii_rxd_host,
	   i_gmii_er_host,	   
	   //htp
	   ov_gmii_txd_host, 
	   o_gmii_tx_en_host,
	   o_gmii_tx_er_host,
	   o_gmii_tx_clk_host,       
       rv_frame_gap,
       
       iv_tsn_chip_version,
       ov_cfg_state,
       pluse_s
);
input                   i_clk;					//125Mhz

input                   i_hard_rst_n;
input                   i_button_rst_n;
input                   i_et_resetc_rst_n;

input       [63:0]      iv_tsn_chip_version;
output      [2:0]       ov_cfg_state;
output      		 	pluse_s;

output      [7:0] 	  	ov_gmii_txd_p0;
output      		 	o_gmii_tx_en_p0;
output      		 	o_gmii_tx_er_p0;
output      		 	o_gmii_tx_clk_p0;

input					i_gmii_rxclk_p1;
input					i_gmii_dv_p1;
input		[7:0]		iv_gmii_rxd_p1;
input					i_gmii_er_p1;
output      [7:0] 	  	ov_gmii_txd_p1;
output      		 	o_gmii_tx_en_p1;
output      		 	o_gmii_tx_er_p1;
output      		 	o_gmii_tx_clk_p1;

output      [7:0] 	  	ov_gmii_txd_p2;
output      		 	o_gmii_tx_en_p2;
output      		 	o_gmii_tx_er_p2;
output      		 	o_gmii_tx_clk_p2;

input					i_gmii_rxclk_host;
input	  				i_gmii_dv_host;
input		[7:0]	 	iv_gmii_rxd_host;
input					i_gmii_er_host;
output      [7:0] 	  	ov_gmii_txd_host;
output      		 	o_gmii_tx_en_host;
output      		 	o_gmii_tx_er_host;
output      		 	o_gmii_tx_clk_host;

wire                    w_timer_rst_gts2others;
wire        [9:0]  	    wv_time_slot ;     
wire                    w_time_slot_switch;

wire        [203:0]  	wv_wr_command;
wire        	        w_wr_command_wr; 
            
wire        [203:0]	    wv_rd_command;
wire          	        w_rd_command_wr;
wire        [203:0]	    wv_rd_command_ack;
                        
wire        [7:0]	    w_gmii_data_ecp2hcp;
wire          	        w_gmii_data_en_ecp2hcp;
wire              	    w_gmii_data_er_ecp2hcp;
wire                    w_gmii_data_clk_ecp2hcp;
            
wire        [7:0]	    w_gmii_data_hcp2ecp;
wire          	        w_gmii_data_en_hcp2ecp;
wire              	    w_gmii_data_er_hcp2ecp;
wire                    w_gmii_data_clk_hcp2ecp;
//reset sync
wire				    w_core_rst_n;
wire				    w_gmii_rst_n_hcp;
wire				    w_gmii_rst_n_p1;
wire				    w_gmii_rst_n_host;
wire				    w_rst_n;
assign w_rst_n = i_hard_rst_n & i_button_rst_n & i_et_resetc_rst_n;

reset_sync core_reset_sync(
.i_clk(i_clk),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_core_rst_n)   
);
reset_sync gmii_p0_reset_sync(
.i_clk(i_clk),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_hcp)   
);
reset_sync gmii_p1_reset_sync(
.i_clk(i_clk),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p1)   
);
reset_sync gmii_host_reset_sync(
.i_clk(i_gmii_rxclk_host),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_host)   
);
wire   [47:0]  wv_syned_global_time;
time_sensitive_end time_sensitive_end_tb(
.i_clk                          (i_clk),
.i_rst_n                        (w_core_rst_n),

.i_gmii_rst_n_hcp               (w_gmii_rst_n_hcp),     
.i_gmii_rst_n_p1                (w_gmii_rst_n_p1),          
.i_gmii_rst_n_host              (w_gmii_rst_n_host), 

.i_gmii_rxclk_hcp               (i_clk),
.i_gmii_dv_hcp                  (w_gmii_data_en_hcp2ecp),
.iv_gmii_rxd_hcp                (w_gmii_data_hcp2ecp),
.i_gmii_er_hcp                  (w_gmii_data_er_hcp2ecp),

.ov_gmii_txd_hcp                (w_gmii_data_ecp2hcp),
.o_gmii_tx_en_hcp               (w_gmii_data_en_ecp2hcp),
.o_gmii_tx_er_hcp               (w_gmii_data_er_ecp2hcp),
.o_gmii_tx_clk_hcp              (w_gmii_data_clk_ecp2hcp),
            
.ov_gmii_txd_p0                 (ov_gmii_txd_p0),
.o_gmii_tx_en_p0                (o_gmii_tx_en_p0),
.o_gmii_tx_er_p0                (o_gmii_tx_er_p0),
.o_gmii_tx_clk_p0               (o_gmii_tx_clk_p0),

.ov_gmii_txd_p1                 (ov_gmii_txd_p1),
.o_gmii_tx_en_p1                (o_gmii_tx_en_p1),
.o_gmii_tx_er_p1                (o_gmii_tx_er_p1),
.o_gmii_tx_clk_p1               (o_gmii_tx_clk_p1),
        
.ov_gmii_txd_p2                 (ov_gmii_txd_p2),
.o_gmii_tx_en_p2                (o_gmii_tx_en_p2),
.o_gmii_tx_er_p2                (o_gmii_tx_er_p2),
.o_gmii_tx_clk_p2               (o_gmii_tx_clk_p2),

.i_gmii_rxclk_p1                (i_gmii_rxclk_p1),
.i_gmii_dv_p1                   (i_gmii_dv_p1),
.iv_gmii_rxd_p1                 (iv_gmii_rxd_p1),
.i_gmii_er_p1                   (i_gmii_er_p1),
            
//hrp           
.i_gmii_rxclk_host              (i_gmii_rxclk_host),
.i_gmii_dv_host                 (i_gmii_dv_host),
.iv_gmii_rxd_host               (iv_gmii_rxd_host),
.i_gmii_er_host                 (i_gmii_er_host),
//htp           
.ov_gmii_txd_host               (ov_gmii_txd_host),
.o_gmii_tx_en_host              (o_gmii_tx_en_host),
.o_gmii_tx_er_host              (o_gmii_tx_er_host),
.o_gmii_tx_clk_host             (o_gmii_tx_clk_host),

.iv_wr_command                  (wv_wr_command),
.i_wr_command_wr                (w_wr_command_wr),        

.iv_rd_command                  (wv_rd_command),
.i_rd_command_wr                (w_rd_command_wr),        
.ov_rd_command_ack              (wv_rd_command_ack), 

.i_timer_rst                    (w_timer_rst_gts2others),
.iv_time_slot                   (wv_time_slot       ),
.i_time_slot_switch             (w_time_slot_switch),
.iv_syned_global_time           (wv_syned_global_time),

.o_fifo_overflow_pulse_host_rx  (), 
.o_fifo_underflow_pulse_host_rx (),
.o_fifo_underflow_pulse_hcp_rx  (),
.o_fifo_overflow_pulse_hcp_rx   (), 
.o_fifo_underflow_pulse_p1_rx   (),
.o_fifo_overflow_pulse_p1_rx    (), 

.o_fifo_overflow_pulse_host_tx  (),
.o_fifo_overflow_pulse_hcp_tx   (),
.o_fifo_overflow_pulse_p1_tx    () 
);
output reg [7:0]       rv_frame_gap/*synthesis noprune*/;
reg                    r_error_flag/*synthesis noprune*/;
reg        [2:0]       fre_state/*synthesis noprune*/;  
localparam             IDLE_S   = 3'd0,
                       PORT_ONE_S  = 3'd1,
                       PORT_THREE_S  = 3'd2;
always @(posedge o_gmii_tx_clk_p1 or negedge w_gmii_rst_n_p1) begin
    if(!w_gmii_rst_n_p1)begin
        rv_frame_gap  <= 8'h0;
        r_error_flag  <= 1'b0;        
        fre_state     <= IDLE_S;
    end
    else begin
        case(fre_state)
            IDLE_S:begin
                r_error_flag  <= 1'b0;  
                if(o_gmii_tx_en_p1 == 1'b1)begin
                    rv_frame_gap     <= 8'h0;
                    fre_state          <= PORT_ONE_S;                    
                end
                else begin
                    rv_frame_gap     <= 8'h0;                   
                    fre_state          <= IDLE_S;
                end
            end
            PORT_ONE_S:begin
                if(o_gmii_tx_en_p1 == 1'b0)begin
                    rv_frame_gap   <= rv_frame_gap + 8'h1;
                    fre_state      <= PORT_THREE_S; 
                end
                else begin
                    rv_frame_gap   <= rv_frame_gap;
                    fre_state      <= PORT_ONE_S; 
                end            
            end            
            PORT_THREE_S:begin
                if(o_gmii_tx_en_p1 == 1'b0)begin 
                    rv_frame_gap   <= rv_frame_gap + 8'h1;
                    fre_state      <= PORT_THREE_S; 
                end
                else begin
                    rv_frame_gap   <= rv_frame_gap;
                    fre_state      <= IDLE_S;
                    if(rv_frame_gap == 8'h0c)begin
                        r_error_flag  <= 1'b0;
                    end
                    else begin
                        r_error_flag  <= 1'b1;
                    end                    
                end            
            end  
        endcase
    end
end
reg        [31:0]      rv_gap10_cnt/*synthesis noprune*/;
reg        [31:0]      rv_gap14_cnt/*synthesis noprune*/;
reg        [31:0]      rv_other_gap_cnt/*synthesis noprune*/;
always @(posedge o_gmii_tx_clk_p1 or negedge w_gmii_rst_n_p1) begin
    if(!w_gmii_rst_n_p1)begin
        rv_gap10_cnt  <= 32'h0;
        rv_gap14_cnt  <= 32'b0;        
        rv_other_gap_cnt <= 32'b0;   
    end
    else begin
        if(r_error_flag && (rv_frame_gap == 8'h0a))begin
            rv_gap10_cnt  <= rv_gap10_cnt + 1'b1;
        end
        else begin
            rv_gap10_cnt  <= rv_gap10_cnt;
        end 
        if(r_error_flag && (rv_frame_gap == 8'h0e))begin
            rv_gap14_cnt  <= rv_gap14_cnt + 1'b1;
        end
        else begin
            rv_gap14_cnt  <= rv_gap14_cnt;
        end
        if(r_error_flag && ((rv_frame_gap != 8'h0e)&&(rv_frame_gap != 8'h0a)))begin
            rv_other_gap_cnt  <= rv_other_gap_cnt + 1'b1;
        end
        else begin
            rv_other_gap_cnt  <= rv_other_gap_cnt;
        end         
    end
end
reg        [11:0]      rv_pkt_byte/*synthesis noprune*/;
reg                    r_pkt_byte_error_flag/*synthesis noprune*/;
reg        [2:0]       pkt_check_state/*synthesis noprune*/;  
localparam             PKT_CHECK_IDLE_S   = 3'd0,
                       PKT_CHECK_CNT_S  = 3'd1,
                       PKT_CHECK_JUDGE_S  = 3'd2;
always @(posedge o_gmii_tx_clk_p1 or negedge w_gmii_rst_n_p1) begin
    if(!w_gmii_rst_n_p1)begin
        rv_pkt_byte  <= 12'h0; 
        r_pkt_byte_error_flag <= 1'b0;        
        pkt_check_state     <= PKT_CHECK_IDLE_S;
    end
    else begin
        case(pkt_check_state)
            PKT_CHECK_IDLE_S:begin  
                r_pkt_byte_error_flag <= 1'b0;   
                if(o_gmii_tx_en_p1 == 1'b1)begin
                    rv_pkt_byte  <= 12'h1;    
                    pkt_check_state  <= PKT_CHECK_CNT_S;                    
                end
                else begin
                    rv_pkt_byte  <= 12'h0;                   
                    pkt_check_state <= PKT_CHECK_IDLE_S;
                end
            end
            PKT_CHECK_CNT_S:begin
                if(o_gmii_tx_en_p1 == 1'b0)begin
                    rv_pkt_byte   <= rv_pkt_byte;
                    pkt_check_state <= PKT_CHECK_JUDGE_S; 
                end
                else begin
                    rv_pkt_byte   <= rv_pkt_byte + 1'b1;
                    pkt_check_state      <= PKT_CHECK_CNT_S; 
                end            
            end            
            PKT_CHECK_JUDGE_S:begin
                pkt_check_state <= PKT_CHECK_IDLE_S; 
                if(rv_pkt_byte == 12'd75)begin 
                    r_pkt_byte_error_flag <= 1'b0;   
                end
                else begin
                    r_pkt_byte_error_flag <= 1'b1;                      
                end            
            end  
        endcase
    end
end
hcp hcp_inst(
.i_clk                 (i_clk),
.i_rst_n               (w_core_rst_n),

.o_timer_rst_gts2others(w_timer_rst_gts2others),
.ov_time_slot          (wv_time_slot),
.o_time_slot_switch    (w_time_slot_switch),
.wv_syned_global_time_gts2tsc  (wv_syned_global_time),

.ov_wr_command         (wv_wr_command),
.o_wr_command_wr       (w_wr_command_wr), 

.ov_rd_command         (wv_rd_command),
.o_rd_command_wr       (w_rd_command_wr),        
.iv_rd_command_ack     (wv_rd_command_ack),        

.i_gmii_rxclk          (w_gmii_data_clk_ecp2hcp),
.i_gmii_dv             (w_gmii_data_en_ecp2hcp),
.iv_gmii_rxd           (w_gmii_data_ecp2hcp),
.i_gmii_er             (w_gmii_data_er_ecp2hcp),       

.ov_gmii_txd           (w_gmii_data_hcp2ecp),
.o_gmii_tx_en          (w_gmii_data_en_hcp2ecp),
.o_gmii_tx_er          (w_gmii_data_er_hcp2ecp),
.o_gmii_tx_clk         (w_gmii_data_clk_hcp2ecp),

.iv_tsn_chip_version   (iv_tsn_chip_version), 
.ov_cfg_state          (ov_cfg_state),  
.o_s_pulse             (pluse_s)         
);
endmodule

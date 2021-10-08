// Copyright (C) 1953-2020 NUDT
// Verilog module name - pkt_distinguish
// Version: V3.2_20210722
// Created:
//         by - wumaowen 
//         at - 7.2021
////////////////////////////////////////////////////////////////////////////
// Description:
//         pkt distinguish TSN or not TSN
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module pkt_distinguish
(
        clk_sys,
        reset_n,
      
        iv_data,
        o_data_rd,
        i_data_empty,
        timer,
    
        ov_data,
        o_data_wr,
        o_tsn_en,
        ov_rec_ts_pdg2pfi,
        o_fifo_underflow_pulse
);

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
// fifo read
output  reg             o_data_rd;
input       [8:0]       iv_data;
input                   i_data_empty;
input       [18:0]      timer;
// data output
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
output  reg             o_tsn_en;
output  reg [18:0]      ov_rec_ts_pdg2pfi;

output  reg             o_fifo_underflow_pulse;

// internal reg&wire
reg         [1:0]       delay_cycle;
reg         [4:0]       rv_cycle_cnt;
reg         [2:0]       pdg_state;
reg         [125:0]     rv_pkt_data;
reg         [15:0]      rv_pkt_type;
localparam  idle_s      = 3'd0,
            head_s      = 3'd1,
            tran_s      = 3'd2,
            tail_s   = 3'd3,
            rdempty_error_s = 3'd4;
 
always @(posedge clk_sys or negedge reset_n) begin
    if(!reset_n) begin
        rv_pkt_data <= 126'b0;
    end
    else begin
        rv_pkt_data <= {rv_pkt_data[116:0],iv_data};
    end
end

 
always@(posedge clk_sys or negedge reset_n) begin
    if(!reset_n) begin
        ov_data         <= 9'b0;
        o_data_wr       <= 1'b0;
        ov_rec_ts_pdg2pfi<= 19'b0;
        o_tsn_en        <= 1'b0;
        o_data_rd       <= 1'b0;
        delay_cycle     <= 2'b0;
		rv_pkt_type        <= 16'b0;
		rv_cycle_cnt     <= 5'b0;
        o_fifo_underflow_pulse <= 1'b0;
        pdg_state <= idle_s;
    end
    else begin
        case(pdg_state)
            idle_s:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
				o_tsn_en            <= 1'b0;
                if(i_data_empty == 1'b0)begin
                    if(delay_cycle == 2'h3)begin 
                        o_data_rd <= 1'b1;
                        delay_cycle <= 2'h0;
                        pdg_state <= head_s;
                    end
                    else if(delay_cycle == 2'h2)begin
                        o_data_rd <= 1'b1;//FIFO in show head mode
                        delay_cycle <= delay_cycle + 1'b1;
                        pdg_state <= idle_s;
                    end
                    else begin
                        o_data_rd           <= 1'b0;
                        delay_cycle <= delay_cycle + 1'b1;
                        pdg_state <= idle_s;
                    end                    
                end
                else begin
                    o_data_rd       <= 1'b0;    
                    delay_cycle     <= 2'h0;                    
                    pdg_state <= idle_s;
                end
            end
            head_s:begin
                o_fifo_underflow_pulse <= 1'b0;
                if(iv_data[8] == 1'b1 && i_data_empty == 1'b0) begin//judge frame head,and make sure pkt body is not empty.
                    o_data_rd           <= 1'b1;
					rv_cycle_cnt        <= 5'b1;
                    pdg_state     <= tran_s;
                end
                else begin
					rv_cycle_cnt        <= rv_cycle_cnt;
                    o_data_rd           <= 1'b0;                    
                    pdg_state     <= idle_s;
                end
            end
            tran_s:begin
				if((iv_data[8] == 1'b0)&&( i_data_empty == 1'b0))begin
                    o_data_rd           <= 1'b1;
					pdg_state     <= tran_s;
					if(rv_cycle_cnt == 5'd14)begin
						rv_cycle_cnt <= rv_cycle_cnt; 
						ov_data      <= rv_pkt_data[125:117];
                        ov_rec_ts_pdg2pfi <= timer;
						o_data_wr     <= 1'b1; 						
					end
					else begin
						rv_cycle_cnt <= rv_cycle_cnt + 1'b1; 
						ov_data             <= 9'b0;
						o_data_wr           <= 1'b0; 							
					end
				end
				else begin
                    ov_data      <= rv_pkt_data[125:117];
                    o_data_wr     <= 1'b1; 	             
					rv_cycle_cnt <= 5'b0; 
					o_data_rd    <= 1'b1;
					pdg_state    <= tail_s;					
				end			
                if(rv_cycle_cnt == 5'd12) begin
                    rv_pkt_type[15:8] <= iv_data[7:0];
                end
                else if(rv_cycle_cnt == 5'd13) begin
                    rv_pkt_type[7:0] <= iv_data[7:0];
                end           
                else begin
					rv_pkt_type <= rv_pkt_type;
                end				
                if((rv_pkt_type == 16'h1800)||(rv_pkt_type == 16'h98f7) ||(rv_pkt_type == 16'hff01))begin//TSN pkt
                    o_tsn_en <= 1'b0;
                end    
                else begin
					 o_tsn_en <= 1'b1;
                end
            end				
            tail_s:begin
                if(rv_pkt_data[125] == 1'b1) begin
                    ov_data             <= rv_pkt_data[125:117];
                    o_data_wr           <= 1'b1;                 
                    pdg_state     <= idle_s;
                end
                else begin
					ov_data    <= rv_pkt_data[125:117];
                    o_data_wr  <= 1'b1;
                    pdg_state     <= tail_s;
                end             
			end	
            default:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
                o_data_rd           <= 1'b0;
                pdg_state     <= idle_s;              
            end
        endcase
    end
end       
endmodule
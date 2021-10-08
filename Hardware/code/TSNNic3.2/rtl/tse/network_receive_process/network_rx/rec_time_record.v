// Copyright (C) 1953-2021 NUDT
// Verilog module name - rec_time_record
// Version: V3.2_20210722
// Created:
//         by - wumaowen 
////////////////////////////////////////////////////////////////////////////
// Description:
//         pkt distinguish TSN or not TSN
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module rec_time_record
(
        clk_sys,
        reset_n,
        
        iv_syned_global_time,
      
        iv_data,
        i_data_wr,
        i_tsn_en,
        iv_time_rec,
    
        ov_data,
        o_data_wr,
        ov_time_rec,
        o_tsn_en,
);

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;

input       [47:0]      iv_syned_global_time;
// fifo read
input       [8:0]       iv_data;
input                   i_data_wr;
input                   i_tsn_en;
input       [18:0]      iv_time_rec;
// data output
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
output  reg [18:0]      ov_time_rec;
output  reg             o_tsn_en;

// internal reg&wire
reg         [11:0]      rv_cycle_cnt;
reg         [47:0]      rv_syned_global_time;
reg         [2:0]       pdg_state;
localparam  idle_s      = 3'd0,
            tran_s      = 3'd1,
            tail_s   = 3'd2,
            rdempty_error_s = 3'd3;
always@(posedge clk_sys or negedge reset_n) begin
    if(!reset_n) begin
        ov_data         <= 9'b0;
        o_data_wr       <= 1'b0;
        ov_time_rec     <= 19'b0;
        o_tsn_en        <= 1'b0;
        
        rv_syned_global_time <= 48'b0;
		rv_cycle_cnt     <= 12'b0;

        pdg_state <= idle_s;
    end
    else begin
        case(pdg_state)
            idle_s:begin
                if(i_data_wr && (iv_data[8]))begin
                    ov_data      <= iv_data;
                    o_data_wr    <= 1'b1; 
                    ov_time_rec  <= iv_time_rec;
                    o_tsn_en     <= i_tsn_en;                    
                    
                    rv_syned_global_time <= iv_syned_global_time;
                    
                    rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                    pdg_state    <= tran_s;                
                end
                else begin
                    ov_data      <= 9'b0;
                    o_data_wr    <= 1'b0;
                    ov_time_rec     <= 19'b0;
                    o_tsn_en        <= 1'b0;
                
                    rv_cycle_cnt <= 12'b0;
                    pdg_state    <= idle_s;
                end
            end
            tran_s:begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
				if(rv_cycle_cnt == 12'd38)begin
                    ov_data      <= {iv_data[8],rv_syned_global_time[47:40]};
                    o_data_wr    <= 1'b1; 
				end
				else if(rv_cycle_cnt == 12'd39)begin
                    ov_data      <= {iv_data[8],rv_syned_global_time[39:32]};
                    o_data_wr    <= 1'b1; 
				end
				else if(rv_cycle_cnt == 12'd40)begin
                    ov_data      <= {iv_data[8],rv_syned_global_time[31:24]};
                    o_data_wr    <= 1'b1; 
				end
				else if(rv_cycle_cnt == 12'd41)begin
                    ov_data      <= {iv_data[8],rv_syned_global_time[23:16]};
                    o_data_wr    <= 1'b1; 
				end
				else if(rv_cycle_cnt == 12'd42)begin
                    ov_data      <= {iv_data[8],rv_syned_global_time[15:8]};
                    o_data_wr    <= 1'b1; 
				end
				else if(rv_cycle_cnt == 12'd43)begin
                    ov_data      <= {iv_data[8],rv_syned_global_time[7:0]};
                    o_data_wr    <= 1'b1;
                    if(i_data_wr && (iv_data[8]))begin
                        pdg_state     <= idle_s;
                    end
                    else begin
                        pdg_state     <= tran_s;
                    end                    
				end                
				else begin
                    ov_data      <= iv_data;
                    o_data_wr     <= 1'b1;
                    if(i_data_wr && (iv_data[8]))begin
                        pdg_state     <= idle_s;
                    end
                    else begin
                        pdg_state     <= tran_s;
                    end                    
				end			
            end				
            default:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
                pdg_state     <= idle_s;              
            end
        endcase
    end
end       
endmodule
// Copyright (C) 1953-2021 NUDT
// Verilog module name - buffer_address_receive
// Version: V3.2.3.20210830
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         extract five tuples of packet.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module buffer_address_receive
(
        i_clk,
        i_rst_n,
       
        iv_data,
        i_data_wr,
        
        i_bufid_wr,
        iv_bufid,
       
        ov_data,
        o_data_wr,
        ov_bufid    
);  
// I/O
// clk & rst  
input                i_clk;
input                i_rst_n;
//pkt input
input        [8:0]   iv_data;
input                i_data_wr;
input        [8:0]   iv_bufid;
input                i_bufid_wr;
//output
output reg   [8:0]   ov_data;
output reg           o_data_wr;
output reg   [8:0]   ov_bufid;
//***************************************************
//          extract five tuple from pkt 
//***************************************************
// internal reg&wire for state machine
reg         [1:0]      rv_bar_state;
localparam  IDLE_S              = 4'd0,
            TRANSMIT_PKT_S      = 4'd1,
            DISCARD_PKT_S       = 4'd2;
always@(posedge i_clk or negedge i_rst_n)begin 
    if(!i_rst_n) begin        
        ov_data <= 9'b0;
        o_data_wr <= 1'b0;
        ov_bufid <= 9'b0;
        rv_bar_state <= IDLE_S;
    end
    else begin
        case(rv_bar_state)
            IDLE_S:begin 
                if(i_data_wr)begin            
                    if(i_bufid_wr)begin
                        ov_data <= iv_data;
                        o_data_wr <= i_data_wr;
                        ov_bufid <= iv_bufid;
                        rv_bar_state <= TRANSMIT_PKT_S; 
                    end
                    else begin
                        ov_data <= 9'b0;
                        o_data_wr <= 1'b0;
                        ov_bufid <= 9'b0;
                        rv_bar_state <= DISCARD_PKT_S;              
                    end
                end
                else begin
                    ov_data <= 9'b0;
                    o_data_wr <= 1'b0;
                    ov_bufid <= 9'b0;
                    rv_bar_state <= IDLE_S;                
                end
            end
            TRANSMIT_PKT_S:begin
                ov_data <= iv_data;
                o_data_wr <= i_data_wr;
                ov_bufid <= iv_bufid;
                if(i_data_wr && iv_data[8])begin
                    rv_bar_state <= IDLE_S; 
                end
                else begin
                    rv_bar_state <= TRANSMIT_PKT_S; 
                end
            end
            DISCARD_PKT_S:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                ov_bufid <= 9'b0;
                if(i_data_wr && iv_data[8])begin
                    rv_bar_state <= IDLE_S; 
                end
                else begin
                    rv_bar_state <= TRANSMIT_PKT_S; 
                end
            end
            default:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                ov_bufid <= 9'b0;
                rv_bar_state <= IDLE_S;
            end
        endcase            
    end
end
endmodule
// Copyright (C) 1953-2021 NUDT
// Verilog module name - traffic_police
// Version: V3.2.2.20210820
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         descriptor extract
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module traffic_police
(
        i_clk,
        i_rst_n,
        
        
        iv_tsntag,
        iv_pkt_type,
        iv_bufid,
        i_descriptor_wr,
        
        iv_free_bufid_fifo_rdusedw,
        iv_rc_threshold_value,
        iv_be_threshold_value,
        
        o_bufid_ack,
        
        o_pkt_discard_pulse,  
        
        ov_tsntag,
        ov_pkt_type,
        ov_bufid,
        o_descriptor_wr,
        i_descriptor_ack
    );
// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;
//input
//tsntag & bufid output 
input       [47:0]      iv_tsntag;
input       [2:0]       iv_pkt_type;
input       [8:0]       iv_bufid;
input                   i_descriptor_wr;

input       [8:0]       iv_free_bufid_fifo_rdusedw;
input       [8:0]       iv_rc_threshold_value;
input       [8:0]       iv_be_threshold_value;

output reg              o_bufid_ack;

output reg              o_pkt_discard_pulse;  
//tsntag & bufid output 
output reg  [47:0]      ov_tsntag;
output reg  [2:0]       ov_pkt_type;
output reg  [8:0]       ov_bufid;
output reg              o_descriptor_wr;
input                   i_descriptor_ack;

reg         [1:0]       rv_tpo_state;
localparam  IDLE_S      = 2'd0,
            WAIT_ACK_S  = 2'd1;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
        o_bufid_ack         <= 1'b0;
        
        ov_tsntag           <= 48'b0;
        ov_pkt_type         <= 3'b0;
        ov_bufid            <= 9'b0;
        o_descriptor_wr     <= 1'b0;
        
        rv_tpo_state        <= IDLE_S;
        end
    else begin
        case(rv_tpo_state)
            IDLE_S:begin
                if(i_descriptor_wr == 1'b1)begin//head
                    case(iv_pkt_type)
                        3'd3:begin//RC
                            if((iv_free_bufid_fifo_rdusedw <=  iv_rc_threshold_value) || (iv_free_bufid_fifo_rdusedw == 9'h0))begin
                            //discard pkt when bufid under threshold or bufid is used up
                                ov_tsntag           <= 48'b0;
                                ov_pkt_type         <= 3'b0;
                                ov_bufid            <= 9'b0;
                                o_descriptor_wr     <= 1'b0;
                                o_pkt_discard_pulse <= 1'b1;
                                o_bufid_ack         <= 1'b0;
                                rv_tpo_state        <= IDLE_S;
                            end
                            else begin
                                ov_tsntag           <= iv_tsntag;
                                ov_pkt_type         <= iv_pkt_type;
                                ov_bufid            <= iv_bufid;
                                o_descriptor_wr     <= 1'b1;
                                o_pkt_discard_pulse <= 1'b0;
                                o_bufid_ack         <= 1'b1;
                                rv_tpo_state        <=  WAIT_ACK_S;
                            end
                        end
                        
                        3'd6:begin//BE
                            if((iv_free_bufid_fifo_rdusedw <=  iv_rc_threshold_value) || (iv_free_bufid_fifo_rdusedw    <=  iv_be_threshold_value) || (iv_free_bufid_fifo_rdusedw == 9'h0))begin
                            //discard pkt when bufid under threshold or bufid is used up
                                ov_tsntag           <= 48'b0;
                                ov_pkt_type         <= 3'b0;
                                ov_bufid            <= 9'b0;
                                o_descriptor_wr     <= 1'b0;
                                o_pkt_discard_pulse <= 1'b1;
                                o_bufid_ack         <= 1'b0;
                                rv_tpo_state        <= IDLE_S;
                            end
                            else begin
                                ov_tsntag           <= iv_tsntag;
                                ov_pkt_type         <= iv_pkt_type;
                                ov_bufid            <= iv_bufid;
                                o_descriptor_wr     <= 1'b1;
                                o_pkt_discard_pulse <= 1'b0;
                                o_bufid_ack         <= 1'b1;
                                rv_tpo_state        <=  WAIT_ACK_S;
                            end
                        end
                        default:begin
                            if(iv_free_bufid_fifo_rdusedw == 9'h0)begin
                                ov_tsntag           <= 48'b0;
                                ov_pkt_type         <= 3'b0;
                                ov_bufid            <= 9'b0;
                                o_descriptor_wr     <= 1'b0;
                                o_pkt_discard_pulse <= 1'b1;
                                o_bufid_ack         <= 1'b0;
                                rv_tpo_state        <= IDLE_S;
                            end
                            else begin
                                ov_tsntag           <= iv_tsntag;
                                ov_pkt_type         <= iv_pkt_type;
                                ov_bufid            <= iv_bufid;
                                o_descriptor_wr     <= 1'b1;
                                o_pkt_discard_pulse <= 1'b0;
                                o_bufid_ack         <= 1'b1;
                                rv_tpo_state        <=  WAIT_ACK_S;
                            end
                        end
                    endcase
                end
                else begin                    
                    ov_tsntag           <= 48'b0;
                    ov_pkt_type         <= 3'b0;
                    ov_bufid            <= 9'b0;
                    o_descriptor_wr     <= 1'b0;
                    o_pkt_discard_pulse <= 1'b0;
                    o_bufid_ack         <= 1'b0;                    
        
                    rv_tpo_state        <= IDLE_S;
                end
            end
            WAIT_ACK_S:begin   
                o_pkt_discard_pulse <= 1'b0;
                o_bufid_ack         <= 1'b0;            
                if(i_descriptor_ack)begin
                    ov_tsntag           <= 48'b0;
                    ov_pkt_type         <= 3'b0;
                    ov_bufid            <= 9'b0;
                    o_descriptor_wr     <= 1'b0;
                    rv_tpo_state        <= IDLE_S;
                end
                else begin
                    rv_tpo_state    <= WAIT_ACK_S;
                end
            end
            default:begin
                ov_tsntag           <= 48'b0;
                ov_pkt_type         <= 3'b0;
                ov_bufid            <= 9'b0;
                o_descriptor_wr     <= 1'b0;
                o_pkt_discard_pulse <= 1'b0;
                o_bufid_ack         <= 1'b0;                    
    
                rv_tpo_state        <= IDLE_S;
            end
        endcase
    end
end    
endmodule
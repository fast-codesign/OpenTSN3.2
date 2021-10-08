// Copyright (C) 1953-2021 NUDT
// Verilog module name - frame_replication
// Version: V3.2.1.20210817
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         replicate frame
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_replication
(      
       i_clk,
       i_rst_n,
              
       iv_data,
       i_data_wr,
       
       ov_p0_gmii_txd,
       o_p0_gmii_tx_en,
       
       ov_p1_gmii_txd,
       o_p1_gmii_tx_en,
       
       ov_p2_gmii_txd,
       o_p2_gmii_tx_en
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;
// receive pkt data from pkt_centralize_bufm_memory
input      [8:0]       iv_data;
input                  i_data_wr;
// send pkt data from gmii     
output reg [8:0]       ov_p0_gmii_txd;
output reg             o_p0_gmii_tx_en;

output reg [8:0]       ov_p1_gmii_txd;
output reg             o_p1_gmii_tx_en;

output reg [8:0]       ov_p2_gmii_txd;
output reg             o_p2_gmii_tx_en;

reg    [197:0]         rv_data;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data <= 198'b0;
    end
    else begin
        if(i_data_wr)begin
            rv_data <= {rv_data[188:0],iv_data};
        end
        else begin
            rv_data <= {rv_data[188:0],9'b0};
        end
    end
end
////////////////////////////////////////
//        read data from fifo         //
////////////////////////////////////////
reg        [2:0]       fre_state;  
localparam             IDLE_S   = 3'd0,
                       PORT_ONE_S  = 3'd1,
                       PORT_THREE_S  = 3'd2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        ov_p0_gmii_txd     <= 8'h0;
        o_p0_gmii_tx_en    <= 1'b0;
        
        ov_p1_gmii_txd     <= 8'h0;
        o_p1_gmii_tx_en    <= 1'b0;

        ov_p2_gmii_txd     <= 8'h0;
        o_p2_gmii_tx_en    <= 1'b0;        
        fre_state          <= IDLE_S;
    end
    else begin
        case(fre_state)
            IDLE_S:begin
                if(rv_data[197] == 1'b1)begin
                    if(({rv_data[16:9],rv_data[7:0]}==16'hff01)||({rv_data[16:9],rv_data[7:0]}==16'h98f7))begin
                        ov_p0_gmii_txd     <= 8'h0;
                        o_p0_gmii_tx_en    <= 1'b0;
                        
                        ov_p1_gmii_txd     <= rv_data[197:189];
                        o_p1_gmii_tx_en    <= 1'b1;
                        
                        ov_p2_gmii_txd     <= 8'h0;
                        o_p2_gmii_tx_en    <= 1'b0;
                        fre_state          <= PORT_ONE_S;                        
                    end
                    else begin
                        ov_p0_gmii_txd     <= rv_data[197:189];
                        o_p0_gmii_tx_en    <= 1'b1;
                        
                        ov_p1_gmii_txd     <= rv_data[197:189];
                        o_p1_gmii_tx_en    <= 1'b1;
                        
                        ov_p2_gmii_txd     <= rv_data[197:189];
                        o_p2_gmii_tx_en    <= 1'b1;   
                        fre_state          <= PORT_THREE_S;                          
                    end
                end
                else begin
                    ov_p0_gmii_txd     <= 8'h0;
                    o_p0_gmii_tx_en    <= 1'b0;
                    
                    ov_p1_gmii_txd     <= 8'h0;
                    o_p1_gmii_tx_en    <= 1'b0;

                    ov_p2_gmii_txd     <= 8'h0;
                    o_p2_gmii_tx_en    <= 1'b0;        
                    fre_state          <= IDLE_S;
                end
            end
            PORT_ONE_S:begin
                ov_p0_gmii_txd     <= 8'h0;
                o_p0_gmii_tx_en    <= 1'b0;

                ov_p1_gmii_txd     <= rv_data[197:189];
                o_p1_gmii_tx_en    <= 1'b1;
                    
                ov_p2_gmii_txd     <= 8'h0;
                o_p2_gmii_tx_en    <= 1'b0;
                if(rv_data[197])begin
                    fre_state      <= IDLE_S; 
                end
                else begin
                    fre_state      <= PORT_ONE_S; 
                end            
            end            
            PORT_THREE_S:begin
                ov_p0_gmii_txd     <= rv_data[197:189];
                o_p0_gmii_tx_en    <= 1'b1;
                
                ov_p1_gmii_txd     <= rv_data[197:189];
                o_p1_gmii_tx_en    <= 1'b1;
                
                ov_p2_gmii_txd     <= rv_data[197:189];
                o_p2_gmii_tx_en    <= 1'b1; 
                if(rv_data[197])begin
                    fre_state      <= IDLE_S; 
                end
                else begin
                    fre_state      <= PORT_THREE_S; 
                end            
            end  
        endcase
    end
end
endmodule
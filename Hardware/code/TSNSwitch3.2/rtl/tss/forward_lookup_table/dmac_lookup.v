// Copyright (C) 1953-2021 NUDT
// Verilog module name - dmac_lookup
// Version: V3.2.0.20210722
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         lookup dmac forward table.
///////////////////////////////////////////////////////////////////////////


module dmac_lookup
(
        i_clk,
        i_rst_n,
       
        iv_fifo_rdata,
        i_fifo_empty,
		o_fifo_rd,
       
        o_mac_ram_rd,
        ov_mac_ram_raddr,
        iv_mac_ram_rdata,
        
        ov_outport,
        o_entry_hit,
		ov_pkt_type,
		ov_pkt_inport,
        ov_pkt_bufid,
		o_action_req,
        i_action_ack
);
// I/O
// clk & rst  
input               i_clk;
input               i_rst_n;
//
input       [60:0]  iv_fifo_rdata;
input               i_fifo_empty;
output reg          o_fifo_rd;
//read ram
output reg          o_mac_ram_rd;
output reg  [4:0]   ov_mac_ram_raddr;
input       [56:0]  iv_mac_ram_rdata;
//output 
output reg  [8:0]   ov_outport;
output reg          o_entry_hit;
output reg  [2:0]   ov_pkt_type;
output reg  [3:0]   ov_pkt_inport;
output reg  [8:0]   ov_pkt_bufid;
output reg          o_action_req;
input               i_action_ack;
//***************************************************
//          lookup dmac forward table
//***************************************************
// internal reg&wire for state machine 
reg         [3:0]   dlu_state;
localparam  IDLE_S = 4'd0,
            WAIT_FIRST_S = 4'd1,
            WAIT_SECOND_S = 4'd2,
            LOOKUP_TABLE_S = 4'd3,
            WAIT_ACK_S = 4'd4;
always @(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)begin
        ov_mac_ram_raddr <= 5'd0;
        o_mac_ram_rd <= 1'b0;
		
		o_fifo_rd <= 1'b0;

        ov_outport <= 9'b0;
		o_entry_hit <= 1'b0;
		ov_pkt_type <= 3'b0;
		ov_pkt_inport <= 4'b0;
		ov_pkt_bufid <= 9'b0;
        o_action_req <= 1'b0;

        dlu_state <= IDLE_S;
    end
    else begin
        case(dlu_state)
            IDLE_S:begin
				o_fifo_rd <= 1'b0;

				ov_outport <= 9'b0;
				o_entry_hit <= 1'b0;
				ov_pkt_type <= 3'b0;
				ov_pkt_inport <= 4'b0;
				ov_pkt_bufid <= 9'b0;
				o_action_req <= 1'b0;
                if(!i_fifo_empty)begin
					ov_mac_ram_raddr <= 5'd0;
					o_mac_ram_rd <= 1'b1;
					
					dlu_state <= WAIT_FIRST_S;
                end
                else begin
                    ov_mac_ram_raddr <=5'd0;
                    o_mac_ram_rd <=1'b0;
                    
                    dlu_state <= IDLE_S;                
                end
            end
            WAIT_FIRST_S:begin//get data of reading ram after 2 cycles. 
                o_mac_ram_rd <= 1'b1;
                ov_mac_ram_raddr <= ov_mac_ram_raddr + 1'b1;
                dlu_state <= WAIT_SECOND_S;
			end
			WAIT_SECOND_S:begin 
                o_mac_ram_rd <= 1'b1;
                ov_mac_ram_raddr <= ov_mac_ram_raddr + 1'b1;
                dlu_state <= LOOKUP_TABLE_S;
			end
			LOOKUP_TABLE_S:begin
				if(iv_mac_ram_rdata[47:0] != 48'b0)begin//table entry is valid
					if(iv_mac_ram_rdata[47:0] == iv_fifo_rdata[60:13])begin//match entry
						o_mac_ram_rd <= 1'b0;
						ov_mac_ram_raddr <= 5'b0;
						
                        o_fifo_rd <= 1'b1;

						ov_outport <= iv_mac_ram_rdata[56:48];
						o_entry_hit <= 1'b1;
						ov_pkt_type <= 3'd6;
						ov_pkt_inport <= iv_fifo_rdata[12:9];
						ov_pkt_bufid <= iv_fifo_rdata[8:0];
						o_action_req <= 1'b1;
                        
						dlu_state <= WAIT_ACK_S;	                    
					end
					else begin//not match entry
						if(ov_mac_ram_raddr == 5'h01)begin//not match all entries.
							o_mac_ram_rd <= 1'b0;
							ov_mac_ram_raddr <= 5'b0;
                            
							o_fifo_rd <= 1'b1;

							ov_outport <= ~{9'd1 << iv_fifo_rdata[12:9]};
							o_entry_hit <= 1'b0;
							ov_pkt_type <= 3'd6;
							ov_pkt_inport <= iv_fifo_rdata[12:9];
							ov_pkt_bufid <= iv_fifo_rdata[8:0];
							o_action_req <= 1'b1;
                            
							dlu_state <= WAIT_ACK_S;                          
						end
						else begin
							o_mac_ram_rd <= 1'b1;
							ov_mac_ram_raddr <= ov_mac_ram_raddr + 1'b1;
							
							o_fifo_rd <= 1'b0;

							ov_outport <= 9'b0;
							o_entry_hit <= 1'b0;
							ov_pkt_type <= 3'b0;
							ov_pkt_inport <= 4'b0;
							ov_pkt_bufid <= 9'b0;
							o_action_req <= 1'b0;
							dlu_state <= LOOKUP_TABLE_S;                      
						end        
					end
                end
                else begin//table entry is invalid
					o_mac_ram_rd <= 1'b0;
					ov_mac_ram_raddr <= 5'b0;
					
					o_fifo_rd <= 1'b1;

					ov_outport <= ~{9'd1 << iv_fifo_rdata[12:9]};
					o_entry_hit <= 1'b0;
					ov_pkt_type <= 3'd6;
					ov_pkt_inport <= iv_fifo_rdata[12:9];
					ov_pkt_bufid <= iv_fifo_rdata[8:0];
					o_action_req <= 1'b1;
					
					dlu_state <= WAIT_ACK_S;  
                end				
			end
            WAIT_ACK_S:begin
			    o_fifo_rd <= 1'b0;
                if(i_action_ack)begin
					ov_outport <= 9'b0;
					o_entry_hit <= 1'b0;
					ov_pkt_type <= 3'b0;
					ov_pkt_inport <= 4'b0;
					ov_pkt_bufid <= 9'b0;
					o_action_req <= 1'b0;
                    dlu_state <= IDLE_S;                      
                end
                else begin
                    dlu_state <= WAIT_ACK_S;   
                end
            end
            default:begin
                ov_mac_ram_raddr <= 5'd0;
                o_mac_ram_rd <= 1'b0;

				ov_outport <= 9'b0;
				o_entry_hit <= 1'b0;
				ov_pkt_type <= 3'b0;
				ov_pkt_inport <= 4'b0;
				ov_pkt_bufid <= 9'b0;
				o_action_req <= 1'b0;
                
                dlu_state <= IDLE_S;            
            end
        endcase
    end
end
endmodule           
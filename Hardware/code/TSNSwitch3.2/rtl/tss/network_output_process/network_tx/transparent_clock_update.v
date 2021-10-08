// Copyright (C) 1953-2021 NUDT
// Verilog module name - transparent_clock_update
// Version: V3.1.1.20210831
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         parse pkt,and calculates and updatas the transparent clock for PTP
///////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module transparent_clock_update
(
       i_clk,
       i_rst_n,
              
       iv_pkt_data,
       i_pkt_data_wr,
       
       ov_pkt_data,
       o_pkt_data_wr,
       
       i_timer_rst           
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input      [8:0]       iv_pkt_data;
input                  i_pkt_data_wr;
// send pkt data from gmii     
output reg [7:0]       ov_pkt_data;
output reg             o_pkt_data_wr;
// local timer rst signal
input                  i_timer_rst;  

reg       [71:0]       rv_pkt_data;

////////////////////////////////////////
//              state                 //
////////////////////////////////////////
reg        [6:0]        rv_pkt_cycle_cnt;
reg                     r_ptp_enabled;    //it is ptp pkt
reg        [18:0]       rv_pkt_rec_timestamp; //record ptp pkt receive time from TSNTag
reg        [63:0]       rv_transparent_clock;
reg        [3:0]        rv_tc_calculation_state;          

////////////////////////////////////////
//        save pkt data in register   //
////////////////////////////////////////
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        rv_pkt_data   <= 72'h0;
    end
    else begin
        if(i_pkt_data_wr == 1'b1)begin//write a pkt data to register
            rv_pkt_data  <= {rv_pkt_data[62:0],iv_pkt_data};      
        end
        else begin
            rv_pkt_data   <= {rv_pkt_data[62:0],9'b0};
        end
    end
end

////////////////////////////////////////
//              timer                 //
////////////////////////////////////////
reg         [18:0]      rv_timer;

always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        rv_timer    <= 19'h0;
    end
    else begin  
        if(i_timer_rst == 1'b1)begin
            rv_timer    <= 19'h0;
        end
        else begin
            if(rv_timer == 19'h7A11f)begin
                rv_timer    <= 19'h0;
            end
            else begin
                rv_timer    <= rv_timer + 19'h1;
            end
        end
    end
end
   
localparam              IDLE_S    = 3'd0,
                        JUDGE_PTP_S  = 3'd1,
                        CALCULATE_TC_S = 3'd2,
                        TRANS_S   = 3'd3;   
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        o_pkt_data_wr        <= 1'b0;
        r_ptp_enabled        <= 1'b0;
        ov_pkt_data          <= 8'h0;
        rv_transparent_clock <= 64'h0;
        rv_pkt_rec_timestamp <= 19'h0;
        rv_tc_calculation_state <= IDLE_S;
    end
    else begin
        case(rv_tc_calculation_state)
            IDLE_S: begin
				r_ptp_enabled        <= 1'b0;
				rv_transparent_clock <= 64'h0;
				rv_pkt_rec_timestamp <= 19'h0;                 
				if(rv_pkt_data[71] == 1'b1)begin
					o_pkt_data_wr    <= 1'b1;
					ov_pkt_data      <= rv_pkt_data[70:63];
					rv_pkt_cycle_cnt <= 7'h0;
					rv_tc_calculation_state <= JUDGE_PTP_S;
					end
				else begin
					o_pkt_data_wr    <= 1'b0;
				    ov_pkt_data      <= 8'h0;
					rv_pkt_cycle_cnt <= 7'h0;
					rv_tc_calculation_state <= IDLE_S;
				end
			end
            
			JUDGE_PTP_S:begin
			    o_pkt_data_wr    <= 1'b1;
				ov_pkt_data      <= rv_pkt_data[70:63]; 
				rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt+1'd1;
				if(rv_pkt_cycle_cnt == 7'd10)begin
				    rv_pkt_rec_timestamp[18:16]  <= rv_pkt_data[65:63];
				end
				else if(rv_pkt_cycle_cnt == 7'd11)begin
					rv_pkt_rec_timestamp[15:8]  <= rv_pkt_data[70:63];
				end
				else if(rv_pkt_cycle_cnt == 7'd12)begin
					rv_pkt_rec_timestamp[7:0]  <= rv_pkt_data[70:63];
				end
                else begin                
                    rv_pkt_rec_timestamp <= rv_pkt_rec_timestamp;
                end

				if(rv_pkt_cycle_cnt == 7'd12)begin
					if({rv_pkt_data[7:0],iv_pkt_data[7:0]} == 16'h98f7)begin
                        r_ptp_enabled  <= 1'b1;
                    end
                    else begin
                        r_ptp_enabled <= 1'b0;
                    end
				end                
				else begin
				    r_ptp_enabled  <= r_ptp_enabled;					
				end

				if(rv_pkt_cycle_cnt == 7'd12)begin
					rv_tc_calculation_state <= CALCULATE_TC_S;
				end
                else begin                
                    rv_tc_calculation_state <= JUDGE_PTP_S;
                end             
			end 
			                     
            CALCULATE_TC_S:begin//updata calculates clock of ptp 
                o_pkt_data_wr    <= 1'b1;
				rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt+7'd1;
				if(rv_pkt_cycle_cnt < 7'd28)begin
				    ov_pkt_data      <= rv_pkt_data[70:63]; 
				end
				else if(rv_pkt_cycle_cnt == 7'd28)begin
			        ov_pkt_data      <= rv_pkt_data[70:63];
                    if(r_ptp_enabled)begin					
						if(rv_timer < rv_pkt_rec_timestamp)begin// calculates and updatas transparent clock,and write it to pkt data  
							rv_transparent_clock <= {rv_pkt_data[61:54],rv_pkt_data[52:45],rv_pkt_data[43:36],rv_pkt_data[34:27],rv_pkt_data[25:18],rv_pkt_data[16:9],rv_pkt_data[7:0],iv_pkt_data[7:0]} + (rv_timer + 19'h7A11f) - rv_pkt_rec_timestamp;
						end
						else begin
							rv_transparent_clock <= {rv_pkt_data[61:54],rv_pkt_data[52:45],rv_pkt_data[43:36],rv_pkt_data[34:27],rv_pkt_data[25:18],rv_pkt_data[16:9],rv_pkt_data[7:0],iv_pkt_data[7:0]} + rv_timer - rv_pkt_rec_timestamp;
						end
				    end
					else begin
					    rv_transparent_clock <= rv_transparent_clock;
					end
			    end
                else begin
				    if(r_ptp_enabled)begin	
						case(rv_pkt_cycle_cnt)                           
							7'd29:ov_pkt_data    <= rv_transparent_clock  [63:56];
							7'd30:ov_pkt_data    <= rv_transparent_clock  [55:48];
							7'd31:ov_pkt_data    <= rv_transparent_clock  [47:40];
							7'd32:ov_pkt_data    <= rv_transparent_clock  [39:32];
							7'd33:ov_pkt_data    <= rv_transparent_clock  [31:24];
							7'd34:ov_pkt_data    <= rv_transparent_clock  [23:16];
							7'd35:ov_pkt_data    <= rv_transparent_clock  [15:8];
							7'd36:ov_pkt_data    <= rv_transparent_clock  [7:0];
							default:begin
								ov_pkt_data <= rv_pkt_data[70:63];
							end						
						endcase
					end
					else begin
					    ov_pkt_data <= rv_pkt_data[70:63];
					end
			    end
                if(rv_pkt_cycle_cnt == 7'd36)begin
				    rv_tc_calculation_state <= TRANS_S;
				end
				else begin
				    rv_tc_calculation_state <= CALCULATE_TC_S;
				end
            end
			TRANS_S:begin
			    ov_pkt_data <= rv_pkt_data[70:63];
			    o_pkt_data_wr    <= 1'b1;
			    if(rv_pkt_data[71] == 1'b1)begin
				    rv_tc_calculation_state <= IDLE_S;
				end
				else begin
				    rv_tc_calculation_state <= TRANS_S;
				end
			
			end
            default:begin
				o_pkt_data_wr        <= 1'b0;
				r_ptp_enabled        <= 1'b0;
	            rv_pkt_cycle_cnt <= 7'h0;
				ov_pkt_data          <= 8'h0;
				rv_transparent_clock <= 64'h0;
				rv_pkt_rec_timestamp <= 19'h0; 
                rv_tc_calculation_state       <= IDLE_S;
            end
        endcase
    end
end
endmodule 
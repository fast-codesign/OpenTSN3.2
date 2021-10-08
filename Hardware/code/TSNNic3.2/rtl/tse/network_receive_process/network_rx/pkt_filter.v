// Copyright (C) 1953-2020 NUDT
// Verilog module name - pkt_filter
// Version: V3.2_20210722
// Created:
//         by - fenglin 
//         at -7.2021
////////////////////////////////////////////////////////////////////////////
// Description:
//         GMII interface output
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module pkt_filter
(
        clk_sys,
        reset_n,

        port_type,
        cfg_finish,
        
        iv_data,
        i_data_wr,
        i_tsn_en,		
        iv_rec_ts_pdg2pfi,     

        ov_data,
        o_data_wr,
        ov_rec_ts,
		o_tsn_en,

        o_pkt_valid_pulse,
        report_pom_state
);

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
//configuration
input                   port_type;
input       [1:0]       cfg_finish;
// fifo read

input       [8:0]       iv_data;
input                   i_data_wr;
input                   i_tsn_en;
//iv_rec_ts_pdg2pfi
input       [18:0]      iv_rec_ts_pdg2pfi;
// data output
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
output  reg [18:0]      ov_rec_ts;
output  reg             o_tsn_en;

output  reg             o_pkt_valid_pulse;// receiced pkt's count pulse signal
reg         [1:0]       delay_cycle;
output      [1:0]       report_pom_state;
reg         [2:0]       pom_state;
assign report_pom_state = pom_state[1:0];
// internal reg&wire
localparam  idle_s      = 3'd0,
            tsn_s      = 3'd1,			
            standard_s      = 3'd2,
			tran_s     = 3'd3,
			discard_s= 3'd4;
            
always@(posedge clk_sys or negedge reset_n)begin
    if(!reset_n) begin
        ov_data         <= 9'b0;
        o_data_wr       <= 1'b0;
        ov_rec_ts       <= 19'b0;
        pom_state <= idle_s;
        end
    else begin
        case(pom_state)
            idle_s:begin
				ov_data         <= 9'b0;
			    o_data_wr       <= 1'b0;
				o_tsn_en        <= 1'b0;
                if((i_data_wr)&&(!i_tsn_en))begin
                    if((port_type == 1'b1 && (cfg_finish == 2'b01 || cfg_finish == 2'b10 || cfg_finish == 2'b11)))begin//port_type:1 input standard pkt. cfg_finish:00 discard all pkt; 01,10,11 passthrough all pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
						o_tsn_en            <= i_tsn_en;
                        ov_rec_ts           <= iv_rec_ts_pdg2pfi;
                        pom_state     <= tran_s;
                    end
                    else if(port_type == 1'b0 && cfg_finish == 2'b01 && iv_data[7:5] == 3'b101)begin//port_type:0 input mapped pkt;cfg_finish:01 only passthrough NMAC pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
						o_tsn_en            <= i_tsn_en;						
                        ov_rec_ts           <= iv_rec_ts_pdg2pfi;
                        pom_state     <= tran_s;
                    end
                    else if(port_type == 1'b0 && cfg_finish == 2'b10 && ((iv_data[7:5] != 3'b000) && (iv_data[7:5] != 3'b001) && (iv_data[7:5] != 3'b010)))begin//port_type:0 input mapped pkt;cfg_finish:10 only passthrough not TS pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
						o_tsn_en            <= i_tsn_en;						
                        ov_rec_ts           <= iv_rec_ts_pdg2pfi;
                        pom_state     <= tran_s;
                    end
                    else if(port_type == 1'b0 && cfg_finish == 2'b11)begin//port_type:0 input mapped pkt;cfg_finish:11 passthrough all pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
						o_tsn_en            <= i_tsn_en;						
                        ov_rec_ts           <= iv_rec_ts_pdg2pfi;
                        pom_state     <= tran_s;
                    end
                    else begin
                        ov_data             <= 9'b0;
                        o_data_wr           <= 1'b0;
						o_tsn_en            <= 1'b0;						
                        ov_rec_ts           <= 19'b0;
                        pom_state     <= discard_s;
                    end
                end		
                else if((i_data_wr)&&(i_tsn_en== 1'b1)) begin   
                    if(cfg_finish !== 2'b00)begin
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
						o_tsn_en            <= i_tsn_en;						
                        ov_rec_ts           <= iv_rec_ts_pdg2pfi;
                        pom_state     <= tran_s;
                    end
                    else begin
                        ov_data             <= 9'b0;
                        o_data_wr           <= 1'b0;
						o_tsn_en            <= 1'b0;
                        ov_rec_ts           <= 19'b0;
                        pom_state     <= discard_s;
                    end				
                end
				else begin
					ov_rec_ts           <= 19'b0;
					pom_state <= idle_s;

                end
			end		
            tran_s:begin
                ov_rec_ts           <= 19'b0;
                if(iv_data[8] == 1'b0) begin//middle
                    ov_data             <= iv_data;
                    o_data_wr           <= 1'b1;  
					o_tsn_en            <= i_tsn_en;					
                    pom_state     <= tran_s;
                end
                else if(iv_data[8] == 1'b1) begin//tail
                    ov_data             <= iv_data;
                    o_pkt_valid_pulse   <= 1'b1;
                    o_data_wr           <= 1'b1;                   
                    pom_state     <= idle_s;
                end                
                else begin
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;
                    pom_state     <= idle_s;
                end
            end
            discard_s:begin
                if(iv_data[8] == 1'b1) begin//tail
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;                   
                    pom_state     <= idle_s;
                end
                else begin
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;
                    pom_state     <= discard_s;
                end             
            end
            default:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
				o_tsn_en            <= 1'b0;
                ov_rec_ts           <= 19'b0;
                pom_state     <= idle_s;              
            end
        endcase
    end
end       
endmodule
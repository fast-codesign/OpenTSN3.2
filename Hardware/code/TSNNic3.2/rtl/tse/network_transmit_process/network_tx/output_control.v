// Copyright (C) 1953-2020 NUDT
// Verilog module name - output_control
// Version: V3.1.0.20210713
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         128bits pkt change to 8bits pkt
//         one network interface have one output_control 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module output_control
(
       i_clk,
       i_rst_n,

       iv_pkt_descriptor,
       i_pkt_descriptor_wr,
       
       iv_pkt_data,
       i_pkt_data_wr,
       
       o_pkt_rd_req,
       o_pkt_tx_finish,
       i_read_first_data,
       
       ov_pkt_data,
       o_pkt_data_wr,
       
       ov_opc_state         
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;
// receive pkt data from pkt_centralize_bufm_memory
input      [133:0]     iv_pkt_data;
input                  i_pkt_data_wr;
input      [56:0]      iv_pkt_descriptor;              
input                  i_pkt_descriptor_wr; 
// send pkt data from gmii     
output reg [8:0]       ov_pkt_data;
output reg             o_pkt_data_wr;
// read finish and read request to pkt_read_control
output                 o_pkt_rd_req;
output                 o_pkt_tx_finish;

input                  i_read_first_data;

output reg  [2:0]      ov_opc_state;
//***************************************************
//               cache tsntag 
//***************************************************
reg      [47:0] rv_tsntag;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        rv_tsntag <= 48'b0;
    end
    else begin  
        if(i_pkt_descriptor_wr)begin
            rv_tsntag <= iv_pkt_descriptor[56:9];
        end
        else begin
            rv_tsntag <= rv_tsntag;
        end
    end
end
////////////////////////////////////////
//        save pkt data in register   //
////////////////////////////////////////
//use two register save pkt data
//when a register was have data,use other register save data
//when two register was have data,have not data input this module
reg       [134:0]       rv_pkt_data_0;//save the pkt data,include 1bit valid,2bits first&last flag,4bits unvalid bytes,128bits data
reg       [134:0]       rv_pkt_data_1;//save the pkt data
reg                     r_reg0_finish;//the register0 have send finish
reg                     r_reg1_finish;//the register1 have send finish
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        rv_pkt_data_0   <= 135'h0;
        rv_pkt_data_1   <= 135'h0;
    end
    else begin
        if((i_pkt_data_wr == 1'b1)&&(rv_pkt_data_0[134] == 1'b0))begin//write a pkt data to register0
            //rv_pkt_data_0           <= {1'b1,iv_pkt_data};
            rv_pkt_data_1[133:0]    <= rv_pkt_data_1[133:0];
            if(iv_pkt_data[133:132] == 2'b01)begin
                if((iv_pkt_data[31:16] == 16'h0800)&&(rv_tsntag != iv_pkt_data[127:80]))begin
                    rv_pkt_data_0 <= {1'b1,iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:32],16'h1800,iv_pkt_data[15:0]};
                end
                else begin
                    rv_pkt_data_0 <= {1'b1,iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:0]};                  
                end            
            end
            else begin
                rv_pkt_data_0           <= {1'b1,iv_pkt_data};
            end
            if(r_reg1_finish == 1'b1)begin//read out a pkt data to register1
                rv_pkt_data_1[134]  <= 1'b0;
            end
            else begin
                rv_pkt_data_1[134]  <= rv_pkt_data_1[134];
            end
        end
        else if((i_pkt_data_wr == 1'b1)&&(rv_pkt_data_1[134] == 1'b0)) begin//write a pkt data to register1
            //rv_pkt_data_1           <= {1'b1,iv_pkt_data};
            rv_pkt_data_0[133:0]    <= rv_pkt_data_0[133:0];
            if(iv_pkt_data[133:132] == 2'b01)begin
                if((iv_pkt_data[31:16] == 16'h0800)&&(rv_tsntag != iv_pkt_data[127:80]))begin
                    rv_pkt_data_1 <= {1'b1,iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:32],16'h1800,iv_pkt_data[15:0]};
                end
                else begin
                    rv_pkt_data_1 <= {1'b1,iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:0]};                  
                end            
            end
            else begin
                rv_pkt_data_1           <= {1'b1,iv_pkt_data};
            end
            if(r_reg1_finish == 1'b1)begin//read out a pkt data to register1
                rv_pkt_data_1[134]  <= 1'b0;
            end
            if(r_reg0_finish == 1'b1)begin//read out a pkt data to register0
                rv_pkt_data_0[134]  <= 1'b0;
            end
            else begin
                rv_pkt_data_0[134]  <= rv_pkt_data_0[134];
            end
        end 
        else begin  
            if(r_reg0_finish == 1'b1)begin//read out a pkt data to register0
                rv_pkt_data_0[134]  <= 1'b0;
            end
            else begin
                rv_pkt_data_0[134]  <= rv_pkt_data_0[134];
            end
            
            if(r_reg1_finish == 1'b1)begin//read out a pkt data to register1
                rv_pkt_data_1[134]  <= 1'b0;
            end
            else begin
                rv_pkt_data_1[134]  <= rv_pkt_data_1[134];
            end
        end
    end
end

////////////////////////////////////////////////////////
//    send read_req signal and pkt_tx_finish signal   //
////////////////////////////////////////////////////////
wire                    w_pkt_last_data;//receive pkt last cycle data
assign  w_pkt_last_data = (iv_pkt_data[133:132] == 2'b10)?1'b1:1'b0;
assign  o_pkt_tx_finish = (w_pkt_last_data && i_pkt_data_wr)?1'b1:1'b0;

assign  o_pkt_rd_req    = ((rv_pkt_data_0[134] == 1'b0)||(rv_pkt_data_1[134] == 1'b0)) ? 1'b1:1'b0;
////////////////////////////////////////
//              state                 //
////////////////////////////////////////
reg        [6:0]        rv_pkt_cycle_cnt; //128bits pkt data count
reg                     r_send_pkt_reg;   //record read pkt from reg0 or reg 1
reg        [3:0]        rv_send_pkt_cnt;  //8bits pkt data count
reg        [3:0]        rv_wite_pkt_cnt;  //12 cycle pkt wite
reg        [3:0]        rv_last_pkt_valid; //pkt last 128bits data valid bytes count
           
localparam              IDLE_S             = 3'd0,
                        STRAT_S            = 3'd1,
                        TRANS_FIRST_DATA_S = 3'd2,
                        CHOISE_S           = 3'd3,
                        TRANS_S            = 3'd4,
                        WITE_S             = 3'd5;

always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        o_pkt_data_wr        <= 1'b0;
        r_reg0_finish        <= 1'b0;
        r_reg1_finish        <= 1'b0;
        rv_send_pkt_cnt      <= 4'h0;
        rv_wite_pkt_cnt         <= 4'h0;
        rv_pkt_cycle_cnt     <= 7'h0;   
        ov_pkt_data          <= 9'h0;
        r_send_pkt_reg       <= 1'h0;
        rv_last_pkt_valid    <= 4'd0;
        ov_opc_state            <= IDLE_S;
    end
    else begin
        case(ov_opc_state)
            IDLE_S:begin//lookup the pkt head from register0 or register1
                
                r_reg0_finish    <= 1'b0;
                r_reg1_finish    <= 1'b0;
                  
                rv_wite_pkt_cnt  <= 4'h0;
                rv_last_pkt_valid<= 4'd0;
                if(i_read_first_data)begin
                    rv_send_pkt_cnt <= 1'd1;
                    ov_pkt_data     <= 9'h155;
                    o_pkt_data_wr   <= 1'b1;                
                    ov_opc_state         <= STRAT_S;
                end
                else begin
                    o_pkt_data_wr    <= 1'b0;
                    rv_send_pkt_cnt  <= 4'h0; 
                    ov_opc_state         <= IDLE_S;
                end
            end
            
            STRAT_S:begin//generate frame first and send form gmii
                r_reg0_finish        <= 1'b0;
                r_reg1_finish        <= 1'b0;
                /*if(rv_send_pkt_cnt == 4'd0)begin
                    rv_send_pkt_cnt <= rv_send_pkt_cnt + 4'd1;
                    ov_pkt_data     <= 9'h155;
                    o_pkt_data_wr   <= 1'b1;
                    ov_opc_state       <= STRAT_S;                    
                end
                else 
                */
                if(rv_send_pkt_cnt < 4'd7)begin
                    rv_send_pkt_cnt <= rv_send_pkt_cnt + 4'd1;
                    ov_pkt_data     <= 9'h055;
                    o_pkt_data_wr   <= 1'b1;
                    ov_opc_state       <= STRAT_S;
                end
                else begin//rv_send_pkt_cnt == 4'd7
                    rv_send_pkt_cnt <= rv_send_pkt_cnt + 4'd1;
                    ov_pkt_data     <= 9'h0d5;
                    o_pkt_data_wr   <= 1'b1;
                    ov_opc_state    <= TRANS_FIRST_DATA_S;
                end
            end
            TRANS_FIRST_DATA_S:begin
                if((rv_pkt_data_0[134] == 1'b1)&&(rv_pkt_data_0[133:132] == 2'b01))begin
                    r_send_pkt_reg       <= 1'h0;
                    rv_pkt_cycle_cnt     <= 7'h1;
                                            
                    ov_pkt_data     <= {1'b0,rv_pkt_data_0[127:120]};
                    o_pkt_data_wr   <= 1'b1;
                    rv_send_pkt_cnt <= 4'd1;
                    rv_last_pkt_valid <= 4'd15;
                    ov_opc_state     <= TRANS_S;
                end
                else if((rv_pkt_data_1[134] == 1'b1)&&(rv_pkt_data_1[133:132] == 2'b01))begin
                    r_send_pkt_reg       <= 1'h1;
                    rv_pkt_cycle_cnt     <= 7'h1;

                    ov_pkt_data     <= {1'b0,rv_pkt_data_1[127:120]};
                    o_pkt_data_wr   <= 1'b1;
                    rv_send_pkt_cnt <= 4'd1;
                    rv_last_pkt_valid<= 4'd15;
                    ov_opc_state       <= TRANS_S;
                end
                else begin
                    rv_pkt_cycle_cnt     <= 7'h0;   
                    r_send_pkt_reg       <= 1'h0;
                    
                    ov_pkt_data          <= 9'h0;
                    o_pkt_data_wr        <= 1'b0;
                    rv_send_pkt_cnt      <= 4'h0;
                    rv_last_pkt_valid    <= 4'd0;                
                
                    ov_opc_state            <= IDLE_S;
                end
            end
            CHOISE_S:begin//transparent data
                r_reg0_finish        <= 1'b0;
                r_reg1_finish        <= 1'b0;
                if(r_send_pkt_reg == 1'b0)begin
                    if(rv_pkt_data_1[134] == 1'b1)begin
                        r_send_pkt_reg  <= 1'b1;
                        ov_opc_state    <= TRANS_S;
                        rv_send_pkt_cnt <= 4'd1;
                        if(rv_pkt_data_1[133:132] == 2'b10)begin
                            rv_last_pkt_valid   <= 4'd15 - rv_pkt_data_1[131:128];
                        end
                        else begin
                            rv_last_pkt_valid   <= 4'd15;
                        end
						if(rv_pkt_data_1[131:128] == 4'hf)begin
							ov_pkt_data     <= {1'b1,rv_pkt_data_1[127:120]};
                            o_pkt_data_wr   <= 1'b1;
						end
						else begin
							ov_pkt_data     <= {1'b0,rv_pkt_data_1[127:120]};
                            o_pkt_data_wr   <= 1'b1;								
						end
                    end
                    else begin
                        r_send_pkt_reg  <= r_send_pkt_reg;
                        ov_pkt_data     <= ov_pkt_data;
                        o_pkt_data_wr   <= 1'b0;
                        ov_opc_state        <= CHOISE_S;
                    end
                end
                else begin
                    if(rv_pkt_data_0[134] == 1'b1)begin
                        r_send_pkt_reg  <= 1'b0;
                        ov_opc_state    <= TRANS_S;
                        rv_send_pkt_cnt <= 4'd1;
                        if(rv_pkt_data_0[133:132] == 2'b10)begin
                            rv_last_pkt_valid   <= 4'd15 - rv_pkt_data_0[131:128];
                        end
                        else begin
                            rv_last_pkt_valid   <= 4'd15;
                        end
						if(rv_pkt_data_0[131:128] == 4'hf)begin
							ov_pkt_data     <= {1'b1,rv_pkt_data_0[127:120]};
                            o_pkt_data_wr   <= 1'b1;
						end
						else begin
							ov_pkt_data     <= {1'b0,rv_pkt_data_0[127:120]};
                            o_pkt_data_wr   <= 1'b1;								
						end
                    end
                    else begin
                        r_send_pkt_reg <= r_send_pkt_reg;
                        ov_pkt_data   <= ov_pkt_data;
                        o_pkt_data_wr <= 1'b0;
                        ov_opc_state  <= CHOISE_S;
                    end
                end
            end
            
            TRANS_S:begin// transmit pkt data in the register
                rv_send_pkt_cnt  <= rv_send_pkt_cnt +4'h1;
                if(r_send_pkt_reg == 1'b0)begin
                    case(rv_send_pkt_cnt)
                        4'h1:ov_pkt_data[7:0]    <= rv_pkt_data_0[119:112];
                        4'h2:ov_pkt_data[7:0]    <= rv_pkt_data_0[111:104];
                        4'h3:ov_pkt_data[7:0]    <= rv_pkt_data_0[103:96];
                        4'h4:ov_pkt_data[7:0]    <= rv_pkt_data_0[95:88];
                        4'h5:ov_pkt_data[7:0]    <= rv_pkt_data_0[87:80];    
                        4'h6:ov_pkt_data[7:0]    <= rv_pkt_data_0[79:72];
                        4'h7:ov_pkt_data[7:0]    <= rv_pkt_data_0[71:64];
                        4'h8:ov_pkt_data[7:0]    <= rv_pkt_data_0[63:56];
                        4'h9:ov_pkt_data[7:0]    <= rv_pkt_data_0[55:48];
                        4'ha:ov_pkt_data[7:0]    <= rv_pkt_data_0[47:40];
                        4'hb:ov_pkt_data[7:0]    <= rv_pkt_data_0[39:32];
                        4'hc:ov_pkt_data[7:0]    <= rv_pkt_data_0[31:24];
                        4'hd:ov_pkt_data[7:0]    <= rv_pkt_data_0[23:16];    
                        4'he:ov_pkt_data[7:0]    <= rv_pkt_data_0[15:8];
                        4'hf:ov_pkt_data[7:0]    <= rv_pkt_data_0[7:0];  
                    endcase
                    if(rv_send_pkt_cnt < rv_last_pkt_valid)begin
                        rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt;
                        r_reg0_finish    <= 1'b0;
                        o_pkt_data_wr    <= 1'b1;
                        ov_opc_state     <= TRANS_S;
                    end
                    else begin
                        r_reg0_finish    <= 1'b1;
                        if(rv_pkt_data_0[133:132] == 2'b10)begin
                            rv_pkt_cycle_cnt <= 7'h0;
                            if(rv_last_pkt_valid == 4'h0)begin
                                ov_pkt_data[8] <= 1'b0;
                                o_pkt_data_wr    <= 1'b0;
                            end
                            else begin
                                ov_pkt_data[8] <= 1'b1;
                                o_pkt_data_wr    <= 1'b1;
                            end
                            ov_opc_state        <= WITE_S;
                        end
                        else begin
                            ov_pkt_data[8] <= 1'b0;
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 7'h1;
                            o_pkt_data_wr    <= 1'b1;
                            ov_opc_state        <= CHOISE_S;
                        end
                    end
                end
                else begin
                    case(rv_send_pkt_cnt)
                        4'h1:ov_pkt_data[7:0]    <= rv_pkt_data_1[119:112];
                        4'h2:ov_pkt_data[7:0]    <= rv_pkt_data_1[111:104];
                        4'h3:ov_pkt_data[7:0]    <= rv_pkt_data_1[103:96];
                        4'h4:ov_pkt_data[7:0]    <= rv_pkt_data_1[95:88];
                        4'h5:ov_pkt_data[7:0]    <= rv_pkt_data_1[87:80];    
                        4'h6:ov_pkt_data[7:0]    <= rv_pkt_data_1[79:72];
                        4'h7:ov_pkt_data[7:0]    <= rv_pkt_data_1[71:64];
                        4'h8:ov_pkt_data[7:0]    <= rv_pkt_data_1[63:56];
                        4'h9:ov_pkt_data[7:0]    <= rv_pkt_data_1[55:48];
                        4'ha:ov_pkt_data[7:0]    <= rv_pkt_data_1[47:40];
                        4'hb:ov_pkt_data[7:0]    <= rv_pkt_data_1[39:32];
                        4'hc:ov_pkt_data[7:0]    <= rv_pkt_data_1[31:24];
                        4'hd:ov_pkt_data[7:0]    <= rv_pkt_data_1[23:16];    
                        4'he:ov_pkt_data[7:0]    <= rv_pkt_data_1[15:8];
                        4'hf:ov_pkt_data[7:0]    <= rv_pkt_data_1[7:0];  
                    endcase
                    if(rv_send_pkt_cnt < rv_last_pkt_valid)begin
                        rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt;
                        r_reg1_finish    <= 1'b0;
                        o_pkt_data_wr    <= 1'b1;
                        ov_opc_state        <= TRANS_S;
                    end
                    else begin
                        r_reg1_finish    <= 1'b1;
                        if(rv_pkt_data_1[133:132] == 2'b10)begin
                            rv_pkt_cycle_cnt <= 7'h0;
                            if(rv_last_pkt_valid == 4'h0)begin
                                ov_pkt_data[8] <= 1'b0;
                                o_pkt_data_wr    <= 1'b0;
                            end
                            else begin
                                ov_pkt_data[8] <= 1'b1;
                                o_pkt_data_wr    <= 1'b1;
                            end
                            ov_opc_state        <= WITE_S;
                        end    
                        else begin
                            ov_pkt_data[8] <= 1'b0;
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 7'h1;
                            o_pkt_data_wr    <= 1'b1;
                            ov_opc_state        <= CHOISE_S;
                        end
                    end
                end
            end
            
            WITE_S:begin//generate frame pitch ,14 bytes
                o_pkt_data_wr   <= 1'b0;
                r_reg0_finish   <= 1'b0;
                r_reg1_finish   <= 1'b0;
                if(rv_wite_pkt_cnt < 4'd15)begin
                    ov_opc_state   <= WITE_S;
                    rv_wite_pkt_cnt  <= rv_wite_pkt_cnt + 4'h1; 
                end
                else begin
                    ov_opc_state <= IDLE_S;
                    rv_wite_pkt_cnt  <= 4'h0;
                end
            end         
            default:begin
               o_pkt_data_wr     <= 1'b0;
               r_reg0_finish     <= 1'b0;
               r_reg1_finish     <= 1'b0;
               rv_send_pkt_cnt   <= 4'h0;
               rv_pkt_cycle_cnt  <= 7'h0;   
               ov_pkt_data       <= 9'h0;
               
               ov_opc_state         <= IDLE_S;
            end
        endcase
    end
end

endmodule
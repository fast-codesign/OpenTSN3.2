// ram_32_131.v

// Generated using ACDS version 15.0 145

`timescale 1 ps / 1 ps
module ram_32_131 (
		input  wire [130:0] data_a,    //  ram_input.datain_a
		input  wire [130:0] data_b,    //           .datain_b
		input  wire [4:0]   address_a, //           .address_a
		input  wire [4:0]   address_b, //           .address_b
		input  wire         wren_a,    //           .wren_a
		input  wire         wren_b,    //           .wren_b
		input  wire         clock,     //           .clock
		input  wire         rden_a,    //           .rden_a
		input  wire         rden_b,    //           .rden_b
		output wire [130:0] q_a,       // ram_output.dataout_a
		output wire [130:0] q_b        //           .dataout_b
	);

	ram_32_131_ram_2port_150_evjlkiq ram_2port_0 (
		.data_a    (data_a),    //  ram_input.datain_a
		.data_b    (data_b),    //           .datain_b
		.address_a (address_a), //           .address_a
		.address_b (address_b), //           .address_b
		.wren_a    (wren_a),    //           .wren_a
		.wren_b    (wren_b),    //           .wren_b
		.clock     (clock),     //           .clock
		.rden_a    (rden_a),    //           .rden_a
		.rden_b    (rden_b),    //           .rden_b
		.q_a       (q_a),       // ram_output.dataout_a
		.q_b       (q_b)        //           .dataout_b
	);

endmodule

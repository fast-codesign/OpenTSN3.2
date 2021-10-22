
module ram_62_256 (
	data_a,
	data_b,
	address_a,
	address_b,
	wren_a,
	wren_b,
	clock,
	rden_a,
	rden_b,
	q_a,
	q_b);	

	input	[61:0]	data_a;
	input	[61:0]	data_b;
	input	[7:0]	address_a;
	input	[7:0]	address_b;
	input		wren_a;
	input		wren_b;
	input		clock;
	input		rden_a;
	input		rden_b;
	output	[61:0]	q_a;
	output	[61:0]	q_b;
endmodule

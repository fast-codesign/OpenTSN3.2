
module suhddpsram512x4_rq (
	data_a,
	data_b,
	address_a,
	address_b,
	wren_a,
	wren_b,
	clock,
	rden_a,
	rden_b,
	aclr,
	q_a,
	q_b);	

	input	[3:0]	data_a;
	input	[3:0]	data_b;
	input	[8:0]	address_a;
	input	[8:0]	address_b;
	input		wren_a;
	input		wren_b;
	input		clock;
	input		rden_a;
	input		rden_b;
	input		aclr;
	output	[3:0]	q_a;
	output	[3:0]	q_b;
endmodule

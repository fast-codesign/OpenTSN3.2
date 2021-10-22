
module suhddpsram65536x134_s (
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

	input	[133:0]	data_a;
	input	[133:0]	data_b;
	input	[15:0]	address_a;
	input	[15:0]	address_b;
	input		wren_a;
	input		wren_b;
	input		clock;
	input		rden_a;
	input		rden_b;
	input		aclr;
	output	[133:0]	q_a;
	output	[133:0]	q_b;
endmodule

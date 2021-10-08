
module RAM9_512 (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	rden,
	aclr,
	q);	

	input	[8:0]	data;
	input	[8:0]	wraddress;
	input	[8:0]	rdaddress;
	input		wren;
	input		clock;
	input		rden;
	input		aclr;
	output	[8:0]	q;
endmodule

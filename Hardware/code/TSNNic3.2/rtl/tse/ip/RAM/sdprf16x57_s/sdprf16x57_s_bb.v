
module sdprf16x57_s (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	rden,
	aclr,
	q);	

	input	[56:0]	data;
	input	[3:0]	wraddress;
	input	[3:0]	rdaddress;
	input		wren;
	input		clock;
	input		rden;
	input		aclr;
	output	[56:0]	q;
endmodule

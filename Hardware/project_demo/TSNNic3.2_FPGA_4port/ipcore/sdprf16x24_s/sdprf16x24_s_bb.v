
module sdprf16x24_s (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	rden,
	aclr,
	q);	

	input	[23:0]	data;
	input	[3:0]	wraddress;
	input	[3:0]	rdaddress;
	input		wren;
	input		clock;
	input		rden;
	input		aclr;
	output	[23:0]	q;
endmodule


module dcm_fifo9x256 (
	data,
	wrreq,
	rdreq,
	clock,
	aclr,
	q,
	usedw,
	full,
	empty);	

	input	[8:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		aclr;
	output	[8:0]	q;
	output	[7:0]	usedw;
	output		full;
	output		empty;
endmodule

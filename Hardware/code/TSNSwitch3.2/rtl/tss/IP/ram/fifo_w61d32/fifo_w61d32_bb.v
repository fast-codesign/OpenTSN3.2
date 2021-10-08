
module fifo_w61d32 (
	data,
	wrreq,
	rdreq,
	clock,
	aclr,
	q,
	usedw,
	full,
	empty);	

	input	[60:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		aclr;
	output	[60:0]	q;
	output	[4:0]	usedw;
	output		full;
	output		empty;
endmodule

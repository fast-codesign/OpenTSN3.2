
module fifo_w14d16 (
	data,
	wrreq,
	rdreq,
	clock,
	aclr,
	q,
	usedw,
	full,
	empty);	

	input	[13:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		aclr;
	output	[13:0]	q;
	output	[3:0]	usedw;
	output		full;
	output		empty;
endmodule

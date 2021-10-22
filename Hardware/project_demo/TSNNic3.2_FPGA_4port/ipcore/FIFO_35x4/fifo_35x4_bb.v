
module fifo_35x4 (
	data,
	wrreq,
	rdreq,
	clock,
	aclr,
	q,
	usedw,
	full,
	empty);	

	input	[34:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		aclr;
	output	[34:0]	q;
	output	[1:0]	usedw;
	output		full;
	output		empty;
endmodule

	suhddpsram16384x9_s u0 (
		.data_a    (<connected-to-data_a>),    //  ram_input.datain_a
		.data_b    (<connected-to-data_b>),    //           .datain_b
		.address_a (<connected-to-address_a>), //           .address_a
		.address_b (<connected-to-address_b>), //           .address_b
		.wren_a    (<connected-to-wren_a>),    //           .wren_a
		.wren_b    (<connected-to-wren_b>),    //           .wren_b
		.clock     (<connected-to-clock>),     //           .clock
		.rden_a    (<connected-to-rden_a>),    //           .rden_a
		.rden_b    (<connected-to-rden_b>),    //           .rden_b
		.aclr      (<connected-to-aclr>),      //           .aclr
		.q_a       (<connected-to-q_a>),       // ram_output.dataout_a
		.q_b       (<connected-to-q_b>)        //           .dataout_b
	);


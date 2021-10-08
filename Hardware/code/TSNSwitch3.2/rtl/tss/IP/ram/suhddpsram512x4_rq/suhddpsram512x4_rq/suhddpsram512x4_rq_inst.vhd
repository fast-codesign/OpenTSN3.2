	component suhddpsram512x4_rq is
		port (
			data_a    : in  std_logic_vector(3 downto 0) := (others => 'X'); -- datain_a
			data_b    : in  std_logic_vector(3 downto 0) := (others => 'X'); -- datain_b
			address_a : in  std_logic_vector(8 downto 0) := (others => 'X'); -- address_a
			address_b : in  std_logic_vector(8 downto 0) := (others => 'X'); -- address_b
			wren_a    : in  std_logic                    := 'X';             -- wren_a
			wren_b    : in  std_logic                    := 'X';             -- wren_b
			clock     : in  std_logic                    := 'X';             -- clock
			rden_a    : in  std_logic                    := 'X';             -- rden_a
			rden_b    : in  std_logic                    := 'X';             -- rden_b
			aclr      : in  std_logic                    := 'X';             -- aclr
			q_a       : out std_logic_vector(3 downto 0);                    -- dataout_a
			q_b       : out std_logic_vector(3 downto 0)                     -- dataout_b
		);
	end component suhddpsram512x4_rq;

	u0 : component suhddpsram512x4_rq
		port map (
			data_a    => CONNECTED_TO_data_a,    --  ram_input.datain_a
			data_b    => CONNECTED_TO_data_b,    --           .datain_b
			address_a => CONNECTED_TO_address_a, --           .address_a
			address_b => CONNECTED_TO_address_b, --           .address_b
			wren_a    => CONNECTED_TO_wren_a,    --           .wren_a
			wren_b    => CONNECTED_TO_wren_b,    --           .wren_b
			clock     => CONNECTED_TO_clock,     --           .clock
			rden_a    => CONNECTED_TO_rden_a,    --           .rden_a
			rden_b    => CONNECTED_TO_rden_b,    --           .rden_b
			aclr      => CONNECTED_TO_aclr,      --           .aclr
			q_a       => CONNECTED_TO_q_a,       -- ram_output.dataout_a
			q_b       => CONNECTED_TO_q_b        --           .dataout_b
		);


	component sdprf512x9_s is
		port (
			data      : in  std_logic_vector(8 downto 0) := (others => 'X'); -- datain
			wraddress : in  std_logic_vector(8 downto 0) := (others => 'X'); -- wraddress
			rdaddress : in  std_logic_vector(8 downto 0) := (others => 'X'); -- rdaddress
			wren      : in  std_logic                    := 'X';             -- wren
			clock     : in  std_logic                    := 'X';             -- clock
			rden      : in  std_logic                    := 'X';             -- rden
			aclr      : in  std_logic                    := 'X';             -- aclr
			q         : out std_logic_vector(8 downto 0)                     -- dataout
		);
	end component sdprf512x9_s;

	u0 : component sdprf512x9_s
		port map (
			data      => CONNECTED_TO_data,      --  ram_input.datain
			wraddress => CONNECTED_TO_wraddress, --           .wraddress
			rdaddress => CONNECTED_TO_rdaddress, --           .rdaddress
			wren      => CONNECTED_TO_wren,      --           .wren
			clock     => CONNECTED_TO_clock,     --           .clock
			rden      => CONNECTED_TO_rden,      --           .rden
			aclr      => CONNECTED_TO_aclr,      --           .aclr
			q         => CONNECTED_TO_q          -- ram_output.dataout
		);


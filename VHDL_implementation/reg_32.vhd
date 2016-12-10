library ieee;
use ieee.std_logic_1164.all;

entity reg_32 is
	port (	clk:		in  std_logic;
			reset:		in  std_logic;						-- reset asserted low
			ce:			in  std_logic;						-- clock enable asserted high
			in_0: 		in  std_logic_vector(31 downto 0); 	-- data input port
			out_0: 		out std_logic_vector(31 downto 0) 	-- data output port
);
end entity reg_32;

architecture beh1 of reg_32 is
begin
	reg: process (clk) is
	begin
	
		if(reset = '0') then
			out_0 <= x"00000000";
		elsif (clk'event and clk = '1') then
				if(ce = '1') then
						out_0 <= in_0;
				end if;
		end if;
	end process;
end architecture;


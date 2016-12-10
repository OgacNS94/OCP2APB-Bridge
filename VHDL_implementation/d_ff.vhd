library ieee;
use ieee.std_logic_1164.all;

entity d_ff is
	port (	clk:		in  std_logic;
			reset:		in  std_logic;	-- reset asserted low
			in_0: 		in  std_logic; 	-- data input port
			out_0: 		out std_logic	-- data output port
);
end entity d_ff;

architecture beh1 of d_ff is
begin
	reg: process (clk) is
	begin
	
		if(reset = '0') then
			out_0 <= '0';
		elsif (clk'event and clk = '1') then
						out_0 <= in_0;
		end if;
	end process;
end architecture;


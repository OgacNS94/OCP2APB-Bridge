library ieee;
use ieee.std_logic_1164.all;

entity control_fsm is
	port (	clk:				in  std_logic;
			reset:				in  std_logic;						-- reset asserted low
			PReady:				in  std_logic;						-- APB slave ready input
			PWrite:				out std_logic;						-- APB R/W signal, read is asserted high
			PSel:				out std_logic;						-- APB master select slave
			PEnable:			out std_logic;						-- APB enable
			PSlverr_delayed:		in  std_logic;					-- APB error bit, delayed by one clock
			MCmd:				in  std_logic_vector(2 downto 0);	-- OCP command input
			SCmdAccept:			out std_logic; 						-- OCP slave command accept output
			SResp:				out std_logic_vector(1 downto 0);	-- OCP slave response
			Data_read_reg_ce:	out std_logic						-- Data read register clock enable, asserted high
);
end entity control_fsm;

architecture behavioral of control_fsm is
 type state_type is (IDLE, WR_SETUP, WR_WAIT, WR_ACCESS, RD_SETUP, RD_WAIT, RD_ACCESS, RD_RESP_ERROR, RD_RESP_DATA_VALID);
 signal state_reg: state_type;

begin
	process (clk, reset)
	begin
		if (reset = '0') then
			state_reg <= idle;
		elsif (clk'event and clk = '1') then
			case state_reg is
				when IDLE =>
					if MCmd = "000" then 		-- OCP IDLE CMD
						state_reg <= IDLE;
					elsif MCmd = "001" then 	-- OCP WRITE CMD
						state_reg <= WR_SETUP;
					elsif MCmd = "010" then 	-- OCP READ CMD
						state_reg <= RD_SETUP;
					else
						state_reg <= IDLE;
					end if;
				when WR_SETUP =>
					state_reg <= WR_WAIT;
				when WR_WAIT =>
					if(PReady = '0') then
						state_reg <= WR_WAIT;
					else
						state_reg <= WR_ACCESS;
					end if; 
				when WR_ACCESS =>
					state_reg <= IDLE;
				when RD_SETUP =>
					state_reg <= RD_WAIT;
				when RD_WAIT =>
					if(PReady = '0') then
						state_reg <= RD_WAIT;
					else
						state_reg <= RD_ACCESS;
					end if;
				when RD_ACCESS =>
					if(PSlverr_delayed = '0') then
						state_reg <= RD_RESP_DATA_VALID;
					else
						state_reg <= RD_RESP_ERROR;
					end if;					
				when RD_RESP_DATA_VALID =>
					state_reg <= IDLE;
				when RD_RESP_ERROR =>
					state_reg <= IDLE;
			end case;
		end if;
	end process;
	
	process (state_reg)
	begin
		case state_reg is
			when IDLE =>
				SCmdAccept <= '0';
				PSel <= '0';
				PEnable <= '0';
				PWrite <= '0';
				SResp <= "00";	-- NULL SLAVE RSP
				Data_read_reg_ce <= '1';
			when WR_SETUP =>
				SCmdAccept <= '0';
				PSel <= '1';
				PEnable <= '0';
				PWrite <= '1';
				SResp <= "00";	-- NULL SLAVE RSP
				Data_read_reg_ce <= '1';
			when WR_WAIT =>
				SCmdAccept <= '0';
				PSel <= '1';
				PEnable <= '1';
				PWrite <= '1';
				SResp <= "00";	-- NULL SLAVE RSP
				Data_read_reg_ce <= '1';
			when WR_ACCESS =>
				SCmdAccept <= '1';
				PSel <= '0';
				PEnable <= '0';
				PWrite <= '0';
				SResp <= "00";	-- NULL SLAVE RSP
				Data_read_reg_ce <= '1';
			when RD_SETUP =>
				SCmdAccept <= '0';
				PSel <= '1';
				PEnable <= '0';
				PWrite <= '0';
				SResp <= "00";	-- NULL SLAVE RSP
				Data_read_reg_ce <= '1';
			when RD_WAIT =>
				SCmdAccept <= '0';
				PSel <= '1';
				PEnable <= '1';
				PWrite <= '0';
				SResp <= "00";	-- NULL SLAVE RSP
				Data_read_reg_ce <= '1';
			when RD_ACCESS =>
				SCmdAccept <= '1';
				PSel <= '0';
				PEnable <= '0';
				PWrite <= '0';
				SResp <= "00";	-- NULL SLAVE RSP
				Data_read_reg_ce <= '1';
			when RD_RESP_DATA_VALID =>
				SCmdAccept <= '0';
				PSel <= '0';
				PEnable <= '0';
				PWrite <= '0';
				SResp <= "01";	-- DATA VALID SLAVE RSP
				Data_read_reg_ce <= '0';
			when RD_RESP_ERROR =>
				SCmdAccept <= '0';
				PSel <= '0';
				PEnable <= '0';
				PWrite <= '0';
				SResp <= "11";  -- ERROR SLAVE RSP
				Data_read_reg_ce <= '0';
		end case;		
	end process;
end behavioral;
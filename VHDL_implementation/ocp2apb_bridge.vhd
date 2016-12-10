library ieee;
use ieee.std_logic_1164.all;

entity ocp2apb_bridge is
	port (	clk:				in  std_logic;
			reset:				in  std_logic;						-- reset asserted low
			--APB SIGNALS
			PAddr:				out  std_logic_vector(31 downto 0);	-- APB address			
			PWrite:				out std_logic;						-- APB R/W signal, read is asserted high
			PSel:				out std_logic;						-- APB master select slave
			PEnable:			out std_logic;						-- APB enable
			PWData:				out std_logic_vector(31 downto 0);	-- APB data for write
			PRData:				in	std_logic_vector(31 downto 0);	-- APB data for read
			PReady:				in  std_logic;						-- APB slave ready input
			PSlverr:			in	std_logic;						-- APB error signal
			--OCP SIGNALS			
			MCmd:				in  std_logic_vector(2 downto 0);	-- OCP command input
			MAddr:				in	std_logic_vector(31 downto 0);	-- OCP master address
			MData:				in	std_logic_vector(31 downto 0);	-- OCP master data
			SCmdAccept:			out std_logic; 						-- OCP slave command accept output
			SResp:				out std_logic_vector(1 downto 0);	-- OCP slave response
			SData:				out	std_logic_vector(31 downto 0)	-- OCP slave data
);
end entity ocp2apb_bridge;

architecture structural of ocp2apb_bridge is
 
    COMPONENT control_fsm
    PORT(
			clk:				in  std_logic;
			reset:				in  std_logic;						-- reset asserted low
			PReady:				in  std_logic;						-- APB slave ready input
			PWrite:				out std_logic;						-- APB R/W signal, read is asserted high
			PSel:				out std_logic;						-- APB master select slave
			PEnable:			out std_logic;						-- APB enable
			PSlverr_delayed:		in  std_logic;				-- APB error bit, delayed by one clock
			MCmd:				in  std_logic_vector(2 downto 0);	-- OCP command input
			SCmdAccept:			out std_logic; 						-- OCP slave command accept output
			SResp:				out std_logic_vector(1 downto 0);	-- OCP slave response
			Data_read_reg_ce:	out std_logic						-- Data read register clock enable, asserted high
        );
    END COMPONENT;

    COMPONENT reg_32
    PORT(
			clk:				in  std_logic;
			reset:				in  std_logic;						-- reset asserted low
			ce:					in  std_logic;						-- clock enable asserted high
			in_0: 				in  std_logic_vector(31 downto 0); 	-- data input port
			out_0: 				out std_logic_vector(31 downto 0) 	-- data output port
        );
    END COMPONENT;
	
	COMPONENT d_ff
	PORT(
			clk:		in  std_logic;
			reset:		in  std_logic;								-- reset asserted low
			in_0: 		in  std_logic; 								-- data input port
			out_0: 		out std_logic								-- data output port
	);
	END COMPONENT;

    signal control2data_read_reg_ce: std_logic;
	signal PSlverr_delayed_s: std_logic;

   	begin

   	CONTROL_UNIT: control_fsm 
	PORT MAP (
	    clk => clk,
        reset => reset,
		PReady => PReady,
		PWrite => PWrite,
		PSel => PSel,
		PEnable => PEnable,
		PSlverr_delayed => PSlverr_delayed_s,
		MCmd => MCmd,
		SCmdAccept => SCmdAccept,
		SResp => SResp,
		Data_read_reg_ce => control2data_read_reg_ce
        );

   	DATA_WRITE_REGISTER: reg_32 
	PORT MAP (
	    clk => clk,
	    reset => reset,
	    ce => '1',
	    in_0 => MData,
	    out_0 => PWData
		);
   	
	DATA_READ_REGISTER: reg_32 
	PORT MAP (
	    clk => clk,
	    reset => reset,
	    ce => control2data_read_reg_ce,
	    out_0 => SData,
	    in_0 => PRData
		);
		
	DATA_ADDRESS_REGISTER: reg_32 
	PORT MAP (
	    clk => clk,
	    reset => reset,
	    ce => '1',
	    in_0 => MAddr,
	    out_0 => PAddr
		);
		
	PSLVERR_DELAY: d_ff
	PORT MAP (
		clk => clk,
	    reset => reset,
	    in_0 => PSlverr,
	    out_0 => PSlverr_delayed_s
		);
		
end architecture structural;
----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer(s): 
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 	 ARM Processor Top Level
-- Module Name:    TopLevel - Behavioral 
-- Project Name: 	 ARM Processor (Single Cycle)
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
--    08/08/2017 - Modified for use with the Papilio Duo
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity TopLevel is
	Generic ( DELAY : integer := 3 -- DELAY = 20 mS / clk_period
				  );								-- for Simulation, DELAY = 3
    Port ( Clk : in STD_LOGIC;
			  DIR_RIGHT : in STD_LOGIC; 	
	        DIR_LEFT : in STD_LOGIC;  
	        DIR_DOWN : in STD_LOGIC;  
	        DIR_UP : in STD_LOGIC;    
			  SWITCH : in  STD_LOGIC_VECTOR (7 downto 0);
           LED : out  STD_LOGIC_VECTOR (7 downto 0);
			  Seg7_SEG : out STD_LOGIC_VECTOR (6 downto 0); 
			  Seg7_DP  : out STD_LOGIC; 
			  Seg7_AN  : out STD_LOGIC_VECTOR (4 downto 0)
			  );
end TopLevel;

architecture Behavioral of TopLevel is

	COMPONENT debounce
	Generic ( DELAY : integer := 640000 -- DELAY = 20 mS / clk_period
				  );
	PORT(
		clk : IN std_logic;
		sig_in : IN std_logic;          
		sig_out : OUT std_logic
		);
	END COMPONENT;

	COMPONENT HEXon7segDisp
	PORT(
		hex_data_in0 : in  STD_LOGIC_VECTOR (3 downto 0);
      hex_data_in1 : in  STD_LOGIC_VECTOR (3 downto 0);
      hex_data_in2 : in  STD_LOGIC_VECTOR (3 downto 0);
      hex_data_in3 : in  STD_LOGIC_VECTOR (3 downto 0);
		dp_in : IN std_logic_vector(2 downto 0);
		clk : IN std_logic;          
		seg_out : OUT std_logic_vector(6 downto 0);
      an_out : out  STD_LOGIC_VECTOR (3 downto 0);
		dp_out : OUT std_logic
		);
	END COMPONENT;
	
	component ARM 
	port(clk, reset, en_ARM: in  STD_LOGIC;
		  PC:                out STD_LOGIC_VECTOR(31 downto 0);
		  Instr:             in  STD_LOGIC_VECTOR(31 downto 0);
		  MemWrite:          out STD_LOGIC;
		  ALUResult, WriteData: out STD_LOGIC_VECTOR(31 downto 0);
		  ReadData:          in  STD_LOGIC_VECTOR(31 downto 0));
	end component;
	
	component Instruction_Memory
   generic ( data_width : positive := 32; 
				 addr_width : positive := 9);
	port(A:  in  STD_LOGIC_VECTOR(addr_width-1 downto 0);
		  RD: out STD_LOGIC_VECTOR(data_width-1 downto 0));
	end component;
	
	component Data_Memory
   generic ( data_width : positive := 32; 
             addr_width : positive := 9);
	port(clk, WE :  in STD_LOGIC;
				 A :   in STD_LOGIC_VECTOR(addr_width-1 downto 0);
				 WD :  in STD_LOGIC_VECTOR(data_width-1 downto 0);
				 RD :  out STD_LOGIC_VECTOR(data_width-1 downto 0));
	end component;
	
--	-- define function to reverse the ordering of bits of a std_logic_vector signal
--	function reverse (x : std_logic_vector) return std_logic_vector is
--		variable y : std_logic_vector (x'range);
--	begin
--		for i in x'range loop
--			y(i) := x(x'left - (i - x'right));
--		end loop;
--		return y;
--	end;

	-- Constants defining memory address ranges
	constant IM_addr_width : positive := 9;
	constant DM_addr_width : positive := 9;
	
	-- Signal for reversed SWITCH ordering
--	signal SWITCHrev : std_logic_vector(7 downto 0);
	
	-- Signal for Hex Display Controller input
	signal HexDisp : std_logic_vector(15 downto 0) := x"0000";

	-- Signals connecting to instruction memory
	signal PC, Instr: std_logic_vector(31 downto 0);
	
	-- Signals connecting to data memory
	signal DataAddr, WriteData, ReadData : std_logic_vector(31 downto 0);
	signal MemWrite : std_logic;
	
	-- Signals needed to implement reset, run, stop, and single-step functions
	signal reset, run, run_ARM, en_ARM, stop, step, DM_WE : std_logic := '0';
	signal DM_Addr : std_logic_vector(DM_addr_width-1 downto 0);
	
begin
	
	-- Reverse the order of the switches so that SWITCH(0) 
	-- on the Papilio One FPGA board is on the right end
--	SWITCHrev <= reverse(SWITCH);
	
	-- Debounce inputs from momentary switches.
	rst_db: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => DIR_LEFT,
		sig_out => reset 
	);
	
	run_db: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => DIR_UP,
		sig_out => run
	);
	
	stop_db: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => DIR_DOWN,
		sig_out => stop
	);
	
	step_db: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => DIR_RIGHT,
		sig_out => step 
	);

	-- The "run_ARM" signal is '1' when we want the ARM processor to be running
	-- "reset" clears "run_ARM"
	-- When "run" become a '1', run_ARM is set to '1' and is held at a '1' until
	--    a "reset" signal or a "stop" signal is received
	
	process(clk, run, reset)
		variable resrun : std_logic_vector(1 downto 0);
	begin
		resrun := reset & run;
		if rising_edge(clk) then
			if reset = '1' AND run = '0' then
				run_ARM <= '0';
			elsif reset = '0' AND run = '1' then
				run_ARM <= '1';
			elsif reset = '1' AND run = '1' then
				run_arm <= '0';
			else
				null;
			end if;
	   end if;
	end process;

	
	-- The en_ARM signal enables the ARM Processor to change its architecture state
	-- This signal is synchronized to the system clock
	-- When run_ARM is '1', en_ARM is '1'
	-- If run_ARM is '0' and step is '1' for one clock cycle, 
	--    en_ARM will be '1' for one clock cycle
	
	process(clk, run_ARM, step) begin
		if rising_edge(clk) then
			if run_ARM='1' or step='1' then
				en_ARM <= '1';
			else
				en_ARM <= '0';
			end if;
		end if;
	end process;

		
	-- Instantiate Hex to 7-segment controller module
	HEXon7segDisp1: HEXon7segDisp PORT MAP(
		hex_data_in0 => HexDisp(3 downto 0),
		hex_data_in1 => HexDisp(7 downto 4),
		hex_data_in2 => HexDisp(11 downto 8),
		hex_data_in3 => HexDisp(15 downto 12),
		dp_in => "000",  -- no decimal point
		seg_out => Seg7_SEG,
		an_out => Seg7_AN(3 downto 0),
		dp_out => Seg7_DP,
		clk => Clk
	);
	
	Seg7_AN(4) <= '1'; -- Anode 4 is always "off"
		
	-- Instantiate the ARM processor
	i_arm: ARM port map(clk => Clk, reset => reset, en_ARM => en_ARM, PC => PC,  
											Instr => Instr, MemWrite => MemWrite,  
											ALUResult => DataAddr, WriteData => WriteData, 
											ReadData => ReadData);
	
	-- Instantiate the Instruction Memory
	i_imem: Instruction_Memory 
	generic map (data_width => 32, addr_width => IM_addr_width)
	port map(A => PC(IM_addr_width+1 downto 2),RD => Instr);
	
	-- Data Memory Address
	DM_Addr <= DataAddr(DM_addr_width+1 downto 2) when en_ARM = '1' 
						else std_logic_vector(resize(unsigned(SWITCH),DM_Addr'length));
	-- Data Memory Write Enable					
	DM_WE <= en_ARM and MemWrite;					

	-- Instantiate the Data Memory
	i_dmem: Data_Memory 
	generic map (data_width => 32, addr_width => DM_addr_width)
	port map(clk => Clk, WE => DM_WE, A => DM_Addr, 
									       WD => WriteData, RD => ReadData);
		
	-- When program is stopped, the program counter (PC) is displayed 
	-- on the left two characters of the 7-segment display
	-- and the data memory address, A(7 downto 0) is SWITCH and the
	-- data in addressed memory location appearing on ReadData(7 downto 0), 
	-- is displayed on the right two characters of the 7-segment display
	
	process(run_ARM) begin
		if run_ARM='0' then
			HexDisp(15 downto 8) <= PC(7 downto 0);
			HexDisp(7 downto 0) <= ReadData(7 downto 0);
		else
			HexDisp <= (others=>'0');
		end if;
	end process;

	
	-- Instr (27 downto 20) displayed on LEDs
--	LED(7 downto 0) <= Reverse(Instr(27 downto 20));	
	LED(7 downto 0) <= Instr(27 downto 20);	
	
end Behavioral;

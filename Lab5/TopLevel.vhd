----------------------------------------------------------------------------------
-- Company: 		Binghamton University
-- Engineer:		Carl Betcher
-- 
-- Create Date:    17:40:05 10/12/2012 
-- Design Name:   HLSM for Register File
-- Module Name:    TopLevel - Behavioral
-- Project Name:   Lab5
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Revisions:
--		10/11/2014 	Modified for Papilio One
--						Added Generic to override debounce DELAY
--						Added comments to change back to Basys2  
--     7/25/2017  Modified for Papilio Duo
--						Removed references to Basys2 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TopLevel is
	 Generic ( debounce_DELAY : integer := 640000 ); -- DELAY = 20 mS / clk_period
    Port ( 
				Clk : IN  std_logic;
				DIR_Up : IN  std_logic;					
				DIR_Right : IN  std_logic;				
				DIR_Down : IN  std_logic;				
				Switch : IN  std_logic_vector(7 downto 0);
				LED : OUT  std_logic_vector(7 downto 0);
				seg7_SEG : OUT  std_logic_vector(6 downto 0);
				seg7_DP : OUT  std_logic;
				seg7_AN : OUT  std_logic_vector(4 downto 0)
		   );
end TopLevel;

architecture Behavioral of TopLevel is

-- -- The following commented code (and the commented code further down is needed 
-- -- 	when using the Papilio One/Logic Start MegaWing
-- --
--	-- define function to reverse the ordering of bits of a std_logic_vector signal
--	function reverse (x : std_logic_vector) return std_logic_vector is
--	variable y : std_logic_vector (x'range);
--	begin
--		  for i in x'range loop
--				y(i) := x(x'left - (i-x'right));
--		  end loop;
--
--		  return y;
--	end;

--	-- signals used to reverse bit ordering
--	signal Switch_reversed : std_logic_vector(7 downto 0);	 
--	signal W_AddrOut_reversed : std_logic_vector(3 downto 0);
--	signal R_AddrOut_reversed : std_logic_vector(3 downto 0);
	
	-- Declare debounce component
	COMPONENT debounce
	GENERIC (DELAY : integer := 640000);
	PORT(
		sig_in : IN std_logic;
		clk : IN std_logic;          
		sig_out : OUT std_logic
		);
	END COMPONENT;

	-- Declare RegFile_HLSM component
	COMPONENT RegFile_HLSM
	PORT(
		clk : IN std_logic;
		btn0 : IN std_logic;
		btn1 : IN std_logic;
		btn2 : IN std_logic;
		Switch : IN std_logic_vector(7 downto 0);          
		HexDisp : OUT std_logic_vector(15 downto 0);
		W_Addr : OUT std_logic_vector(3 downto 0);
		R_Addr : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	-- Declare HEXon7segDisp component
	COMPONENT HEXon7segDisp
	PORT(
		hex_data_in0 : IN std_logic_vector(3 downto 0);
		hex_data_in1 : IN std_logic_vector(3 downto 0);
		hex_data_in2 : IN std_logic_vector(3 downto 0);
		hex_data_in3 : IN std_logic_vector(3 downto 0);
		dp_in : IN std_logic_vector(2 downto 0);
		clk : IN std_logic;          
		seg_out : OUT std_logic_vector(6 downto 0);
		an_out : OUT std_logic_vector(3 downto 0);
		dp_out : OUT std_logic
		);
	END COMPONENT;

	-- Signals for connecting inputs and outputs of "debouce" circuits
	signal Button : std_logic_vector(2 downto 0);  
	signal btn0 : std_logic;
	signal btn1 : std_logic;
	signal btn2 : std_logic;
	
	-- Signals between datapath and HEXon7segDisp
	signal HexDisp : std_logic_vector(15 downto 0);
	
begin
	
--	-- Reverse the bit ordering of data from switches and data to LEDs	
--	Switch_reversed <= Reverse(Switch);		 
--	LED(3 downto 0) <= Reverse(W_AddrOut_reversed);	
--	LED(7 downto 4) <= Reverse(R_AddrOut_reversed);	
	
	-- For Papilio One, invert push button inputs
--	Button <= not DIR_Down & not DIR_Right & not DIR_Up;  -- Papilio One

	-- For Papilio Duo, buttons are used directly
	Button <= DIR_Down & DIR_Right & DIR_Up;					-- Papilio Duo
	
	-- Instantiate "debounce" for Button 0
		debounce0: debounce 
			GENERIC MAP ( DELAY => debounce_DELAY )
			PORT MAP(		
				sig_in => Button(0),
				clk => Clk,
				sig_out => btn0 
			);

	-- Instantiate "debounce" for Button 1
		debounce1: debounce 
			GENERIC MAP ( DELAY => debounce_DELAY )
			PORT MAP(		
				sig_in => Button(1),
				clk => Clk,
				sig_out => btn1 
			);
		
	-- Instantiate "debounce" for Button 2
		debounce2: debounce 
			GENERIC MAP ( DELAY => debounce_DELAY )
			PORT MAP(		
				sig_in => Button(2),
				clk => Clk,
				sig_out => btn2 
			);
		
	-- Instantiate RegFile_HLSM Module
	RegFile_HLSM1: RegFile_HLSM PORT MAP(
		clk => clk,
		btn0 => btn0,
		btn1 => btn1,
		btn2 => btn2,
--		Switch => Switch_reversed, -- Papilio One
		Switch => Switch,				-- Papilio Duo
		HexDisp => HexDisp,
--		-- Papilio One
--		W_Addr => W_AddrOut_reversed,
--		R_Addr => R_AddrOut_reversed  
		-- Papilio Duo
		W_Addr => LED(7 downto 4),  -- Display R_Addr on LEDs
		R_Addr => LED(3 downto 0)   -- Display W_Addr on LEDs
	);
	
	-- Instantiate Hex to 7-segment conversion module
	HEXon7segDisp1: HEXon7segDisp PORT MAP(
--	-- For Papilio One	
--		hex_data_in0 => HexDisp(3 downto 0),
--		hex_data_in1 => HexDisp(7 downto 4),
--		hex_data_in2 => HexDisp(11 downto 8),
--		hex_data_in3 => HexDisp(15 downto 12),
		hex_data_in0 => HexDisp(15 downto 12),
		hex_data_in1 => HexDisp(11 downto 8),
		hex_data_in2 => HexDisp(7 downto 4),
		hex_data_in3 => HexDisp(3 downto 0),
		dp_in => "000",  -- no decimal point
		seg_out => seg7_SEG,
		an_out => seg7_AN(3 downto 0),
		dp_out => seg7_DP,
		clk => Clk
	);
			
	Seg7_AN(4) <= '1'; -- Anode 4 is always "off"
	
end Behavioral;

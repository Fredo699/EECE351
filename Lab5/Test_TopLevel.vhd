--------------------------------------------------------------------------------
-- Company: 		Binghamton University
-- Engineer:		Carl Betcher
--
-- Create Date:   22:34:55 10/10/2012
-- Design Name:   HLSM for Register File
-- Module Name:   Test_TopLevel.vhd
-- Project Name:  Lab5
-- Target Device:  
-- Tool versions:  
-- Description:
-- Revisions:
--		10/11/2014 	Modified for Papilio One
--						Use reverse function to reorder bits so that LSB is on right
--						Generic to override debounce DELAY for simulation
--						Added comments to change back to Basys2   
--		10/12/2015  Added sum_data procedure to sum the data in the test_data 
--						array that is to be loaded in the RegFile and put the value
--						of the sum in the signal test_sum.
--    07/25/2017  Modified for Papilio Duo. Removed changes made to reverse bit
--                ordering for Papilio One. Removed references to Basys2.
--
-- VHDL Test Bench Created by ISE for module: TopLevel
-- 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Test_TopLevel IS
END Test_TopLevel;
 
ARCHITECTURE behavior OF Test_TopLevel IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    
	 COMPONENT TopLevel
	 Generic ( debounce_DELAY : integer := 640000 ); -- DELAY = 20 mS / clk_period
    PORT(
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
    END COMPONENT;
    
   --Inputs
   signal Clk : std_logic := '0';
   signal DIR_Up : std_logic := '0';
   signal DIR_Right : std_logic := '0';
   signal DIR_Down : std_logic := '0';
   signal Switch : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal seg7_SEG : std_logic_vector(6 downto 0);
   signal seg7_DP : std_logic;
   signal seg7_AN : std_logic_vector(4 downto 0);

	-- Other Signals
	signal Button : std_logic_vector(2 downto 0) := (others => '0'); 
														  --Papilio One use '1'
--	-- For Papilio One, use following for reversed ordered Switches and LEDs
--	signal LED_reversed : std_logic_vector(7 downto 0) := (others => '0');
--	signal Switches_reversed : std_logic_vector(7 downto 0) := (others => '0');
	signal test_sum : unsigned(15 downto 0) := (others => '0');

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
	
--	-- define function to reverse the ordering of bits of a std_logic_vector signal
--	function reverse (x : std_logic_vector) return std_logic_vector is
--	variable y : std_logic_vector (x'range);
--	begin
--		  for i in x'range loop
--				y(i) := x(x'left - i);
--		  end loop;
--		  return y;
--	end;

	-- Test Data
	type test_vector is record
		W_addr : std_logic_vector(3 downto 0);
		R_addr : std_logic_vector(3 downto 0);
		W_data : std_logic_vector(7 downto 0);
	end record;

	type test_data_array is array (natural range <>) of test_vector;
	constant test_data : test_data_array :=
		(
			(x"0", x"0", x"05"),	
			(x"1", x"0", x"0a"),	
			(x"2", x"1", x"05"),
			(x"2", x"1", x"05"),
			(x"3", x"2", x"0a"),	
			(x"4", x"3", x"05"),	
			(x"5", x"4", x"0a"),	
			(x"6", x"5", x"05"),	
			(x"7", x"6", x"0a"),	
			(x"8", x"7", x"05"),	
			(x"9", x"8", x"0a"),	
			(x"a", x"9", x"05"),	
			(x"b", x"a", x"0a"),	
			(x"c", x"b", x"05"),	
			(x"d", x"c", x"0a"),	
			(x"e", x"d", x"05"),	
			(x"f", x"e", x"0a")	
		);

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TopLevel 
		GENERIC MAP ( debounce_DELAY => 3 ) -- set delay to small number for simulation
		PORT MAP (
          Clk => Clk,
          DIR_Up => DIR_Up,
          DIR_Right => DIR_Right,
          DIR_Down => DIR_Down,
          Switch => Switch,
--          LED => LED_reversed,
          LED => LED,
          seg7_SEG => seg7_SEG,
          seg7_DP => seg7_DP,
          seg7_AN => seg7_AN
        );

-- Reverse order of LEDs for Papilio One	
--	LED <= reverse(LED_reversed);	  

	-- map buttons to signals for Papilio Duo
	DIR_Down <= Button(2);
	DIR_Right <= Button(1);
	DIR_Up <= Button(0);	

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
	
 	-- Procedure used to write to one location of the RegFile
	procedure write_RegFile(W_addr, R_addr : std_logic_vector(3 downto 0);
									W_data : std_logic_vector(7 downto 0)) is
		begin
			Switch <= W_addr & R_addr;                   -- Papilio Duo code
			wait for 100 ns; 		Button(0) <= '1';       -- Papilio Duo code
			wait for 100 ns;		Button(0) <= '0';		wait for 100 ns;
			
			-- Put data to be written on switches
--			Switch <= reverse(W_data); -- Papilio One code
			Switch <= W_data; 
			
			-- Load data into register file using button 1
			wait for 100 ns;		Button(1) <= '1';
			wait for 100 ns;		Button(1) <= '0';		wait for 100 ns;
		end procedure;	

	-- Procedure used to sum the data in the test vestors
	procedure sum_data is
		variable sum : unsigned(15 downto 0);
		begin
			sum := (others => '0');
			for i in test_data'range loop
				sum := sum + resize(unsigned(test_data(i).W_data),test_sum'length);
			end loop;
			test_sum <= sum;
		end procedure;

   begin		
		-- Calculate the sum of the data in test vectors
		sum_data;
		
      Button <= (others => '0');       -- Papilio Duo code
		Switch <= (others => '0');
		-- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 
		
		-- Load RegFile using test vectors in "test_data" and the procedure
		--    write_RegFile(W_addr, R_addr, W_data)
		for k in test_data'range loop
			write_RegFile(test_data(k).W_addr, test_data(k).R_addr, 
																				test_data(k).W_data);	
		end loop;
		
		-- Sum the contents of the RegFile using button 2
		Button(2) <= '0';		wait for 100 ns;       -- Papilio Duo code
		Button(2) <= '1';		wait for 100 ns;
		
		-- The sum displayed on the 7-segment display should be the same as "test_sum"
		-- computed by the "sum_data" procedure
				
      wait;
   end process;

END;

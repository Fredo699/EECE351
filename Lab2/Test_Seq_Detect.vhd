--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:54:54 09/13/2017
-- Design Name:   
-- Module Name:   /home/fred/git/EECE151/Lab2/Test_Seq_Detect.vhd
-- Project Name:  Lab2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Seq_Detect
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Test_Seq_Detect IS
END Test_Seq_Detect;
 
ARCHITECTURE behavior OF Test_Seq_Detect IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Seq_Detect
    PORT(
         clk : IN  std_logic;
         clk_enable : IN  std_logic;
         seq : IN  std_logic;
         found : OUT  std_logic;
         state_out : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clk_enable : std_logic := '0';
   signal seq : std_logic := '0';

 	--Outputs
   signal found : std_logic;
   signal state_out : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clk_enable_period : time := 10 ns;
	
	-- Test Data Array
	-- define array record ( a single row of the array)
	type test_data_record is record
		sequence  : std_logic_vector(5 downto 0);
		found_seq : std_logic_vector(5 downto 0);
	end record;
	
	-- define test data array type
	type test_data_type is array (natural range <>) of test_data_record;
	
	-- create constant array
	-- Test Data
	constant test_data : test_data_type :=
		(
			("000000" , "000000"),
			("000010" , "000000"),
			("000100" , "000000"),
			("000110" , "000000"),
			("001000" , "000000"),
			("001010" , "000000"),
			("001100" , "000000"),
			("001110" , "000000"),
			("010000" , "000000"),
			("010010" , "000000"),
			("010100" , "000000"),
			("010110" , "000000"),
			("011000" , "000000"),
			("011010" , "000010"),
			("011100" , "000000"),
			("011110" , "000000"),
			("100000" , "000000"),
			("100010" , "000000"),
			("100100" , "000000"),
			("100110" , "000000"),
			("101000" , "000000"),
			("101010" , "000000"),
			("101100" , "000000"),
			("101110" , "000000"),
			("110000" , "000000"),
			("110010" , "000000"),
			("110100" , "000100"),
			("110110" , "000100"),
			("111000" , "000000"),
			("111010" , "000010"),
			("111100" , "000000"),
			("111110" , "000000")
		);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Seq_Detect PORT MAP (
          clk => clk,
          clk_enable => clk_enable,
          seq => seq,
          found => found,
          state_out => state_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   clk_enable_process :process
   begin
		clk_enable <= '0';
		wait for clk_enable_period/2;
		clk_enable <= '1';
		wait for clk_enable_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
		procedure GenPattern(sequence, found_seq : in std_logic_vector) is
		begin
			wait until falling_edge(clk);
			for i in sequence'range loop
				seq <= sequence(i);
				wait until falling_edge(clk);
				assert found = found_seq(i)
				report "Output value for 'found' is incorrect" severity error;
			end loop;
		end procedure;
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		-- enable the clock
		clk_enable <= '1';
		report "Generating input sequenes and checking 'found' output.";
		
		-- generate test patterns using the GenPattern procedure
		-- and the test_data array
		for k in test_data'range loop
			GenPattern (test_data(k).sequence, test_data(k).found_seq);
			wait for 50 ns;
		end loop;
		report "Simulation finished.";

      wait;
   end process;

END;

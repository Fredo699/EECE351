--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:42:19 09/18/2017
-- Design Name:   
-- Module Name:   /home/fred/git/EECE151/Lab3/TestHexon7segDisp.vhd
-- Project Name:  Lab3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: HEXon7segDisp
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
 
ENTITY TestHexon7segDisp IS
END TestHexon7segDisp;
 
ARCHITECTURE behavior OF TestHexon7segDisp IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT HEXon7segDisp
    PORT(
         hex_data_in0 : IN  std_logic_vector(3 downto 0);
         hex_data_in1 : IN  std_logic_vector(3 downto 0);
         hex_data_in2 : IN  std_logic_vector(3 downto 0);
         hex_data_in3 : IN  std_logic_vector(3 downto 0);
         dp_in : IN  std_logic_vector(2 downto 0);
         seg_out : OUT  std_logic_vector(6 downto 0);
         an_out : INOUT  std_logic_vector(3 downto 0);
         dp_out : OUT  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal hex_data_in0 : std_logic_vector(3 downto 0) := (others => '0');
   signal hex_data_in1 : std_logic_vector(3 downto 0) := (others => '0');
   signal hex_data_in2 : std_logic_vector(3 downto 0) := (others => '0');
   signal hex_data_in3 : std_logic_vector(3 downto 0) := (others => '0');
   signal dp_in : std_logic_vector(2 downto 0) := (others => '0');
   signal clk : std_logic := '0';

	--BiDirs
   signal an_out : std_logic_vector(3 downto 0);

 	--Outputs
   signal seg_out : std_logic_vector(6 downto 0);
   signal dp_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 31.25 ns;
	
	type test_vector is record
		hex_data_in0 : std_logic_vector(3 downto 0);
		hex_data_in1 : std_logic_vector(3 downto 0);
		hex_data_in2 : std_logic_vector(3 downto 0);
		hex_data_in3 : std_logic_vector(3 downto 0);
		dp_in 		 : std_logic_vector(2 downto 0);
	end record;
	
	type test_data_array is array (natural range <>) of test_vector;
	
	constant test_data : test_data_array := (("0101", "1010", "0011", "1100", "000" ),
											  ("0110", "1001", "0111", "1000", "001" ),
											  ("0001", "0010", "0100", "1011", "010" ),
											  ("0000", "1101", "1110", "1111", "100" ));
 
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: HEXon7segDisp PORT MAP (
          hex_data_in0 => hex_data_in0,
          hex_data_in1 => hex_data_in1,
          hex_data_in2 => hex_data_in2,
          hex_data_in3 => hex_data_in3,
          dp_in => dp_in,
          seg_out => seg_out,
          an_out => an_out,
          dp_out => dp_out,
          clk => clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      for k in test_data'range loop
			hex_data_in0 <= test_data(k).hex_data_in0;
			hex_data_in1 <= test_data(k).hex_data_in1;
			hex_data_in2 <= test_data(k).hex_data_in2;
			hex_data_in3 <= test_data(k).hex_data_in3;
			dp_in <= test_data(k).dp_in;
			wait for clk_period*4095;
		end loop;

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;

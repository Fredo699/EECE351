--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:42:10 11/18/2017
-- Design Name:   
-- Module Name:   /home/fred/git/EECE151/SingleCycleArm/Test_Toplevel.vhd
-- Project Name:  SingleCycleArm
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TopLevel
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
 
ENTITY Test_Toplevel IS
END Test_Toplevel;
 
ARCHITECTURE behavior OF Test_Toplevel IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TopLevel
    PORT(
         Clk : IN  std_logic;
         DIR_RIGHT : IN  std_logic;
         DIR_LEFT : IN  std_logic;
         DIR_DOWN : IN  std_logic;
         DIR_UP : IN  std_logic;
         SWITCH : IN  std_logic_vector(7 downto 0);
         LED : OUT  std_logic_vector(7 downto 0);
         Seg7_SEG : OUT  std_logic_vector(6 downto 0);
         Seg7_DP : OUT  std_logic;
         Seg7_AN : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal DIR_RIGHT : std_logic := '0';
   signal DIR_LEFT : std_logic := '0';
   signal DIR_DOWN : std_logic := '0';
   signal DIR_UP : std_logic := '0';
   signal SWITCH : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal Seg7_SEG : std_logic_vector(6 downto 0);
   signal Seg7_DP : std_logic;
   signal Seg7_AN : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
	
	signal reset, run, stop, step : std_logic := '0';
 
BEGIN
	DIR_LEFT <= reset;
	DIR_UP <= run;
	DIR_DOWN <= stop;
	DIR_RIGHT <= step;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TopLevel PORT MAP (
          Clk => Clk,
          DIR_RIGHT => DIR_RIGHT,
          DIR_LEFT => DIR_LEFT,
          DIR_DOWN => DIR_DOWN,
          DIR_UP => DIR_UP,
          SWITCH => SWITCH,
          LED => LED,
          Seg7_SEG => Seg7_SEG,
          Seg7_DP => Seg7_DP,
          Seg7_AN => Seg7_AN
        );

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
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
		
		reset <= '1';
		wait for Clk_period*10;
		reset <= '0';
		
      wait for Clk_period*10;
		
		--stimulus
		run <= '1';
		wait for Clk_period*10;
		run <= '0';
		wait for Clk_period*300;
		reset <= '1';
      wait;
   end process;

END;

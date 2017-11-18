----------------------------------------------------------------------------------
-- Company Name:   Binghamton University
-- Engineer(s):    Fred Frey
-- Create Date:    11:37:21 10/31/2012 
-- Design Name: 
-- Module Name:    DAC_Test_Source - Behavioral 
-- Project Name:   Lab7
-- Description: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DAC_Test_Source is
 	 Generic (MSB : integer := 11);
    Port ( clk : in  STD_LOGIC;
           Sample : in  STD_LOGIC;
           DAC_test_data : out  STD_LOGIC_VECTOR (MSB downto 0));
end DAC_Test_Source;

-- Sawtooth wave for testing output.
architecture Behavioral of DAC_Test_Source is
signal voltage : unsigned(MSB downto 0) := to_unsigned(0, MSB+1);
begin
	DAC_test_data <= std_logic_vector(voltage);
	process(clk) begin
		if rising_edge(clk) then
			if Sample = '1' then
				voltage <= voltage + to_unsigned(1, MSB+1);
			end if;
		end if;
	end process;

end Behavioral;


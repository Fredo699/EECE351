----------------------------------------------------------------------------------
-- Company:  Binghamton University
-- Engineer: Fred Frey
-- 
-- Create Date:    11:21:59 10/27/2017 
-- Design Name: 
-- Module Name:    FIR_Filter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- package declaration for FIR_Coeff_type
package DSDtypes_pkg is
	type FIR_Coeff_type is array (natural range <>) of unsigned(11 downto 0);
end package DSDtypes_pkg;

-- FIR_Filter behavioral description
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.DSDtypes_pkg.all; -- use package defined abpve

entity FIR_Filter is
	Generic (Coeff : FIR_Coeff_type);
	Port ( clk : in STD_LOGIC;
			 Sample : in STD_LOGIC;
			 X : in STD_LOGIC_VECTOR (11 downto 0);
			 Y : out STD_LOGIC_VECTOR (11 downto 0));
end FIR_Filter;

architecture Behavioral of FIR_Filter is
	signal xt0, xt1, xt2 : unsigned (11 downto 0) := to_unsigned(0, 12);
	signal c0x0, c1x1, c2x2 : unsigned (23 downto 0) := to_unsigned(0, 24);
	signal y_int : unsigned (23 downto 0);
begin
	c0x0 <= xt0 * Coeff(0);
	c1x1 <= xt1 * Coeff(1);
	c2x2 <= xt2 * Coeff(2);
	
	Y <= std_logic_vector(y_int(23 downto 12));
	
	process(clk) begin
		if rising_edge(clk) then
			if sample = '1' then
				xt2 <= xt1;
				xt1 <= xt0;
				xt0 <= unsigned(X);
			end if;
		end if;
	end process;
	
	process(clk) begin
		if rising_edge(clk) then
			y_int <= c0x0 + c1x1 + c2x2;
		end if;
	end process;
end Behavioral;


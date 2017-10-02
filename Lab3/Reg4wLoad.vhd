----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:30:18 09/18/2017 
-- Design Name: 
-- Module Name:    Reg4wLoad - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--XXX This code is probably dangerous; I tried to make it use arbitrary vector sizes.
entity Reg4wLoad is
    Port ( I : in  STD_LOGIC_VECTOR;
           clk : in std_logic;
			  load : in std_logic;
			  Q : out  STD_LOGIC_VECTOR);
end Reg4wLoad;

architecture Behavioral of Reg4wLoad is
begin
process(clk, load) begin
	if rising_edge(clk) and load='1' then
		Q <= I;
	end if;
end process;
end Behavioral;


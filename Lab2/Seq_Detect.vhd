----------------------------------------------------------------------------------
-- Company:  Binghamton University
-- Engineer: Fred Frey & Caleb Wagoner
-- 
-- Create Date:    12:36:44 09/13/2017 
-- Design Name: 
-- Module Name:    Seq_Detect - Behavioral 
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

entity Seq_Detect is
    Port ( clk : in  STD_LOGIC;
           clk_enable : in  STD_LOGIC;
           seq : in  STD_LOGIC;
           found : out  STD_LOGIC;
           state_out : out  STD_LOGIC_VECTOR(4 downto 0));
end Seq_Detect;

architecture Behavioral of Seq_Detect is
	type state_type is (s0, s1, s2, s3, s4);
	signal next_state : state_type := s0;
	signal curstate   : state_type := s0;
begin
	process(clk, clk_enable) begin
		if clk_enable='1' and rising_edge(clk) then
			curstate <= next_state;
		end if;
	end process;
	
	process (curstate, seq) begin
		case curstate is
			when s0 =>
				found <= '0';
				state_out <= "00001";
				if seq = '1' then
					next_state <= s1;
				else
					next_state <= s0;
				end if;
			when s1 =>
				found <= '0';
				state_out <= "00010";
				if seq='1' then
					next_state <= s2;
				else
					next_state <= s0;
				end if;
			when s2 =>
				found <= '0';
				state_out <= "00100";
				if seq='0' then
					next_state <= s3;
				else
					next_state <= s2;
				end if;
			when s3 =>
				found <= '0';
				state_out <= "01000";
				if seq='1' then
					next_state <= s4;
				else
					next_state <= s0;
				end if;
			when s4 =>
				found <= '1';
				state_out <= "10000";
				next_state <= s0;
		end case;
	end process;
end Behavioral;


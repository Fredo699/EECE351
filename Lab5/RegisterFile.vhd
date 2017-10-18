----------------------------------------------------------------------------------
-- Company:  Binghamton University
-- Engineer: Fred Frey & Caleb Wagoner
-- 
-- Create Date:    13:09:50 10/09/2017 
-- Design Name: 
-- Module Name:    RegisterFile - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
	 Generic (addr_size : natural := 4;
				 word_size : natural := 8);
    Port ( W_addr : in  STD_LOGIC_VECTOR (addr_size - 1 downto 0);
           R_addr : in  STD_LOGIC_VECTOR (addr_size - 1 downto 0);
           W_data : in  STD_LOGIC_VECTOR (word_size - 1 downto 0);
           W_en : in  STD_LOGIC;
			  clk : in std_logic;
           W_Data_out : out  STD_LOGIC_VECTOR (word_size - 1 downto 0);
           R_Data : out  STD_LOGIC_VECTOR (word_size - 1 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is

type regfile_t is array ((2 ** addr_size) - 1  downto 0) of std_logic_vector(word_size - 1 downto 0);
signal regfile : regfile_t := (others=>(others=>'0'));

--signal w_addr_int : integer := 0;
--signal r_addr_int : integer := 0;

begin
--	w_addr_int <= to_integer(unsigned(w_addr));
--	r_addr_int <= to_integer(unsigned(r_addr));
	
	process (clk) begin
		if rising_edge(clk) then
			if (W_en = '1') then
				RegFile(to_integer(unsigned(W_addr))) <= W_data;
			end if;
		end if;
	end process;
	
	W_data_out <= RegFile(to_integer(unsigned(W_addr)));
	R_data <= RegFile(to_integer(unsigned(R_addr)));

end Behavioral;


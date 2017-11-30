----------------------------------------------------------------------------------
-- Company:  Binghamton University
-- Engineer: Fred Frey
-- 
-- Create Date:    10:57:35 09/29/2017 
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

entity Register_File is
	 Generic(addr_size : natural := 4;
				word_size : natural := 32);
    Port ( A3 	 		 : in  STD_LOGIC_VECTOR (addr_size-1 downto 0);
           WD3 	 	 : in  STD_LOGIC_VECTOR (word_size-1 downto 0);
           A1 	 		 : in  STD_LOGIC_VECTOR (addr_size-1 downto 0);
           A2	 		 : in  STD_LOGIC_VECTOR (addr_size-1 downto 0);
			  R15   	 : in  STD_LOGIC_VECTOR (word_size-1 downto 0);
           WE3   	 	 : in  STD_LOGIC;
           clk    	 : in  STD_LOGIC;
           WD3_Out 	 : out  STD_LOGIC_VECTOR (word_size-1 downto 0);
           RD1 	 : out  STD_LOGIC_VECTOR (word_size-1 downto 0);
			  RD2		 : out  STD_LOGIC_VECTOR (word_size-1 downto 0));
end Register_File;

architecture Behavioral of Register_File is
type regfile_t is array ((2**addr_size)-1 downto 0) of std_logic_vector(word_size-1 downto 0);

signal A3_int : unsigned(addr_size-1 downto 0);
signal A1_int : unsigned(addr_size-1 downto 0);
signal A2_int : unsigned(addr_size-1 downto 0);

signal regfile : regfile_t := (others=>(others=>'0'));

begin

	A3_int <= unsigned(A3);
	
	A1_int <= unsigned(A1);
	A2_int <= unsigned(A2);
	
	process(clk, WE3, WD3) begin
		if rising_edge(clk) and WE3 = '1' then
			regfile(to_integer(A3_int)) <= WD3;
		end if;
	end process;
	
	process(A1_int, R15, regfile) begin	
		if A1_int = 15 then
			RD1 <= R15;
		else
			RD1 <= regfile(to_integer(A1_int));
		end if;
	end process;
	
	process(A2_int, R15, regfile) begin	
		if A2_int = 2**addr_size - 1 then
			RD2 <= R15;
		else
			RD2 <= regfile(to_integer(A2_int));
		end if;
	end process;
	
	WD3_Out <= regfile(to_integer(A3_int));
	
	
end Behavioral;


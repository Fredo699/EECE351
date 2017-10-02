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

entity RegisterFile is
	 Generic(addr_size : natural := 4;
				word_size : natural := 8);
    Port ( A3 	 		 : in  STD_LOGIC_VECTOR (addr_size-1 downto 0);
           WD3 	 	 : in  STD_LOGIC_VECTOR (word_size-1 downto 0);
           A1 	 		 : in  STD_LOGIC_VECTOR (addr_size-1 downto 0);
           A2	 		 : in  STD_LOGIC_VECTOR (addr_size-1 downto 0);
			  Reg_15   	 : in  STD_LOGIC_VECTOR (word_size-1 downto 0);
           WE3   	 	 : in  STD_LOGIC;
           clk    	 : in  STD_LOGIC;
           WD3_Out 	 : out  STD_LOGIC_VECTOR (word_size-1 downto 0);
           R_Data1 	 : out  STD_LOGIC_VECTOR (word_size-1 downto 0);
			  R_Data2	 : out  STD_LOGIC_VECTOR (word_size-1 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is
type regfile_t is array ((2**addr_size)-2 downto 0) of std_logic_vector(word_size-1 downto 0); -- 2^addr - 2 because we use 1 for R15.

signal A3_int : integer;
signal A1_int : integer;
signal A2_int : integer;

signal regfile : regfile_t := (others=>(others=>'0'));

begin

	A3_int <= to_integer(unsigned(A3));
	
	A1_int <= to_integer(unsigned(A1));
	A2_int <= to_integer(unsigned(A2));
	
	process(clk, WE3, WD3) begin
		if rising_edge(clk) and WE3 = '1' then
			regfile(A3_int) <= WD3;
		end if;
	end process;
	
	process(A1_int, Reg_15) begin	
		if A1_int = 2**addr_size - 1 then
			R_Data <= Reg_15;
		else
			R_Data <= regfile(A1_int);
		end if;
	end process;
	
	process(A2_int, Reg_15) begin	
		if A2_int = 2**addr_size - 1 then
			R_Data <= Reg_15;
		else
			R_Data <= regfile(A2_int);
		end if;
	end process;
	
	WD3_Out <= regfile(A3_int);
	
	
end Behavioral;


----------------------------------------------------------------------------------
-- Company:  Binghamton University
-- Engineer: Fred Frey & Caleb Wagoner
-- 
-- Create Date:    13:06:58 09/27/2017 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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

entity ALU is
	Generic (data_size : positive := 32);
	port ( A 			: in std_logic_vector(data_size - 1 downto 0);
			 B 			: in std_logic_vector(data_size - 1 downto 0);
			 ALUControl : in std_logic_vector(2 downto 0);
			 result 		: out std_logic_vector(data_size - 1 downto 0);
			 ALUFlags 	: out std_logic_vector(3 downto 0));
end ALU;

architecture Behavioral of ALU is
signal A_int 		: signed(data_size - 1 downto 0) := to_signed(0, data_size) ;
signal B_int 		: signed(data_size - 1 downto 0) := to_signed(0, data_size) ;
signal result_int : signed(data_size     downto 0) := to_signed(0, data_size+1) ;
signal cout : std_logic;
signal V, C, N, Z : std_logic;
signal Vcond1, Vcond2, Vcond3 : std_logic; -- This is a complicated expression, so I'm breaking it up.

begin
process(ALUControl, A, B) begin
	A_int <= signed(A);
	B_int <= signed(B);
end process;

process(ALUControl, A_int, B_int, result_int) begin
	if ALUControl = "000" then -- ADD
		result_int <= resize(A_int, data_size + 1) + resize(B_int, data_size + 1);
		cout <= result_int(data_size);
	elsif ALUControl = "001" then -- SUB
		result_int <= resize(A_int - B_int, data_size + 1);
		cout <= '0';
	elsif ALUControl = "010" then -- AND
		result_int <= resize(A_int, data_size + 1) and resize(B_int, data_size + 1);
		cout <= '0';
	elsif ALUControl = "011" then -- OR
		result_int <= resize(A_int, data_size + 1) or resize(B_int, data_size + 1);
		cout <= '0';
	elsif ALUControl = "100" then -- EOR
		result_int <= resize(A_int, data_size + 1) xor resize(B_int, data_size + 1);
		cout <= '0';
	elsif ALUControl = "101" then -- NOT
		result_int <= signed(not ('0' & std_logic_vector(B_int)));
		cout <= '0';
	elsif ALUControl = "110" then -- MUL
		result_int <= resize(A_int * B_int, data_size + 1);
		cout <= result_int(data_size);
	elsif ALUControl = "111" then -- SRCB
		result_int <= resize(B_int, data_size + 1);
		cout <= '0';
	else
		result_int <= to_signed(0, data_size + 1);
		cout <= '0';
	end if;
end process;
	
	N <= result_int(data_size - 1);
	Z <= '1' when result_int(data_size - 1 downto 0) = 0 else '0';
	C <= cout and (not ALUControl(1));
	Vcond1 <= '1' when ALUControl(2 downto 1) = "00" else '0';
	Vcond2 <= result_int(data_size - 1) xor A(data_size - 1);
	Vcond3 <= ALUControl(0) xor A(data_size - 1) xor B(data_size - 1);
	V <= Vcond1 and Vcond2 and (not Vcond3);
	ALUFlags <= N & Z & C & V;

	result <= std_logic_vector(result_int(data_size - 1 downto 0));

end Behavioral;


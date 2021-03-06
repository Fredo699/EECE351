----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 Carl Betcher
-- 
-- Create Date:    22:32:43 11/16/2016 
-- Design Name:	 ARM Processor Decoder 
-- Module Name:    Cond_Logic - Behavioral 
-- Project Name: 	 ARM Processor (Single Cycle)
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
--use IEEE.NUMERIC_STD.ALL;

entity Cond_Logic is
    Port ( clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
           Cond : in  STD_LOGIC_VECTOR (3 downto 0);
           ALUFlags : in  STD_LOGIC_VECTOR (3 downto 0);
           FlagW : in  STD_LOGIC_VECTOR (1 downto 0);
           PCS : in  STD_LOGIC;
           RegW : in  STD_LOGIC;
           MemW : in  STD_LOGIC;
			  NextPC : in STD_LOGIC;
           PCWrite : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC;
           MemWrite : out  STD_LOGIC);
end Cond_Logic;

architecture Behavioral of Cond_Logic is

--	signal FlagWrite : std_logic_vector(1 downto 0);
	signal Flags : std_logic_vector(3 downto 0);
	signal CondEx, Next_CondEx : std_logic;
	signal N, Z, C, V : STD_LOGIC;

begin

	-- Conditional Logic checks if instruction should execute
	-- (if not, force PCSrc, RegWrite, and MemWrite to '0')
	-- and possibly updates the Status Register (Flags(3:0))
	
	-- Register the ALU flags
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				Flags(3 downto 2) <= (others => '0');
			elsif FlagW(1) = '1' and Next_CondEx = '1' then
				Flags(3 downto 2) <= ALUFlags(3 downto 2);
			end if;	
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				Flags(1 downto 0) <= (others => '0');
			elsif FlagW(0) = '1' and Next_CondEx = '1' then
				Flags(1 downto 0) <= ALUFlags(1 downto 0);
			end if;	
		end if;
	end process;
	
	process(clk) begin -- CondEx reg control
		if rising_edge(clk) then
			CondEx <= Next_CondEx;
		end if;
	end process;
	
   -- Condition Checking Logic
   N <= Flags(3);  Z <= Flags(2);  C <= Flags(1);  V <= Flags(0);  
	process(Cond, N, Z, C, V) 
	begin
			case Cond is
				when "0000" => Next_CondEx <= Z;							-- EQ
				when "0001" => Next_CondEx <= not Z;						-- NE
				when "0010" => Next_CondEx <= C;							-- CS/HS
				when "0011" => Next_CondEx <= not C;						-- CC/LO
				when "0100" => Next_CondEx <= N;							-- MI
				when "0101" => Next_CondEx <= not N;						-- PL
				when "0110" => Next_CondEx <= V;							-- VS
				when "0111" => Next_CondEx <= not V;						-- VC
				when "1000" => Next_CondEx <= not Z and C;				-- HI
				when "1001" => Next_CondEx <= Z or not C;				-- LS
				when "1010" => Next_CondEx <= not (N xor V);			-- GE
				when "1011" => Next_CondEx <= N xor V;					-- LT
				when "1100" => Next_CondEx <= not Z and not(N xor V);--	GT
				when "1101" => Next_CondEx <= Z or (N xor V);			-- LE
				when "1110" => Next_CondEx <= '1';							-- AL (or none)
				when others => Next_CondEx <= '0';	
			end case;
	end process;

	
	PCWrite  <= (PCS  and CondEx) or NextPC;
	RegWrite <= RegW and CondEx;
	MemWrite <= MemW and CondEx;
	

end Behavioral;


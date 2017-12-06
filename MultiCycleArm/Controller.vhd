----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer(s): 
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
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

entity controller is -- multicycle control decoder
  port(clk, reset:        in  STD_LOGIC;
		 
		 --CondLogic Input:
       Cond:				  in STD_LOGIC_VECTOR(3 downto 0);
		 ALUFlags:			  in STD_LOGIC_VECTOR(3 downto 0);
		 
		 --Decoder Input:
		 Op:					  in STD_LOGIC_VECTOR(1 downto 0);
		 Funct:				  in STD_LOGIC_VECTOR(5 downto 0);
		 Rd:					  in STD_LOGIC_VECTOR(3 downto 0);
		 
		 --Cond Logic output:
		 PCWrite:			  out STD_LOGIC;
		 RegWrite:			  out STD_LOGIC;
		 MemWrite:			  out STD_LOGIC;
		 
		 --Decoder Output:
		 IRWrite:			  out STD_LOGIC;
		 AdrSrc:				  out STD_LOGIC;
		 ResultSrc:			  out STD_LOGIC_VECTOR(1 downto 0);
		 ALUSrcA:			  out STD_LOGIC;
		 ALUSrcB:			  out STD_LOGIC_VECTOR(1 downto 0);
		 ImmSrc:				  out STD_LOGIC_VECTOR(1 downto 0);
		 RegSrc:				  out STD_LOGIC_VECTOR(1 downto 0);
		 ALUControl:		  out STD_LOGIC_VECTOR(1 downto 0));
end controller;

architecture Behavioral of Controller is

component Decoder is
    Port ( clk : in STD_LOGIC;
			  reset: in STD_LOGIC;
			  Op : in  STD_LOGIC_VECTOR (1 downto 0);
           Funct : in  STD_LOGIC_VECTOR (5 downto 0);
           Rd : in  STD_LOGIC_VECTOR (3 downto 0);
			  FlagW : out STD_LOGIC_VECTOR(1 downto 0);
			  PCS : out STD_LOGIC;
			  NextPC : out STD_LOGIC;
			  RegW : out STD_LOGIC;
			  MemW : out STD_LOGIC;
			  IRWrite : out STD_LOGIC;
			  AdrSrc : out STD_LOGIC;
			  ResultSrc : out STD_LOGIC_VECTOR(1 downto 0);
			  ALUSrcA : out STD_LOGIC;
			  ALUSrcB : out STD_LOGIC_VECTOR(1 downto 0);
			  ImmSrc : out STD_LOGIC_VECTOR(1 downto 0);
			  RegSrc : out STD_LOGIC_VECTOR(1 downto 0);
			  ALUControl : out STD_LOGIC_VECTOR(1 downto 0));
end component;


component Cond_Logic is
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
end component;
	
	--Decoder=>CondLogic signals
	signal FlagW : std_logic_vector(1 downto 0);
	signal PCS  : std_logic;
	signal NextPC : std_logic;
	signal RegW : std_logic;
	signal MemW : std_logic;
	

begin
	-- Instantiate the Decoder Function of the Controller
	Inst_Decoder: Decoder PORT MAP(
		clk=>clk, reset=>reset,
		
		--input
		Op=>Op, Funct=>Funct, Rd=>Rd,
		
		--output (sigs)
		FlagW=>FlagW, PCS=>PCS, NextPC=>NextPC, RegW=>RegW, MemW=>MemW,
		
		--output (nodes)
		IRWrite=>IRWrite, AdrSrc=>AdrSrc, ResultSrc=>ResultSrc,
		ALUSrcA=>ALUSrcA, ALUSrcB=>ALUSrcB, ImmSrc=>ImmSrc,
		RegSrc=>RegSrc, ALUControl=>ALUControl
	);

	-- Instantiate the Conditional Logic Function of the Controller
	Inst_Cond_Logic: Cond_Logic PORT MAP(
		clk => clk, reset => reset,
		
		--input (nodes)
		Cond=>Cond, ALUFlags=>ALUFlags,
		
		--input (sigs)
		FlagW=>FlagW, PCS=>PCS, NextPC=>NextPC, RegW=>RegW, MemW=>MemW,
		
		--output
		PCWrite=>PCWrite, RegWrite=>RegWrite, MemWrite=>MemWrite
	);
end Behavioral;


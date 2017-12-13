----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer(s): 
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 
-- Module Name:    ARM - Behavioral 
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

entity ARM is -- single cycle processor
  Generic (addr_size : natural := 9);
  
  port(clk, reset, en_ARM: in STD_LOGIC;
		 SWITCH :				in STD_LOGIC_VECTOR(7 downto 0);
       PCOut: 					out STD_LOGIC_VECTOR(7 downto 0);
		 InstrOut:				out STD_LOGIC_VECTOR(27 DOWNTO 20);
		 ReadDataOut:			out STD_LOGIC_VECTOR(7 DOWNTO 0));
end ARM;

architecture Behavioral of ARM is

component controller is -- multicycle control decoder
  port(clk, reset:        in  STD_LOGIC;
		 
		 --CondLogic Input:
       Cond:				  in STD_LOGIC_VECTOR(3 downto 0);
		 ALUFlags:			  in STD_LOGIC_VECTOR(3 downto 0);
		 
		 --Decoder Input:
		 Op:					  in STD_LOGIC_VECTOR(1 downto 0);
		 Funct:				  in STD_LOGIC_VECTOR(5 downto 0);
		 Rd:					  in STD_LOGIC_VECTOR(3 downto 0);
		 Src12:				  in STD_LOGIC_VECTOR(11 downto 4);
		 en_ARM:				  in STD_LOGIC;
		 
		 --Cond Logic output:
		 PCWrite:			  out STD_LOGIC;
		 RegWrite:			  out STD_LOGIC;
		 MemWrite:			  out STD_LOGIC;
		 
		 --Decoder Output:
		 IRWrite:			  out STD_LOGIC;
		 AdrSrc:				  out STD_LOGIC;
		 decode_state: 	  out STD_LOGIC;
		 ResultSrc:			  out STD_LOGIC_VECTOR(1 downto 0);
		 ALUSrcA:			  out STD_LOGIC;
		 ALUSrcB:			  out STD_LOGIC_VECTOR(1 downto 0);
		 ImmSrc:				  out STD_LOGIC_VECTOR(1 downto 0);
		 RegSrc:				  out STD_LOGIC_VECTOR(1 downto 0);
		 ALUControl:		  out STD_LOGIC_VECTOR(2 downto 0);
		 sh:					  out STD_LOGIC_VECTOR(1 downto 0);
		 shamt5:				  out STD_LOGIC_VECTOR(4 DOWNTO 0));
end component;

component datapath is  
  port(clk, reset, en_ARM: in STD_LOGIC;
		 SWITCH:					in STD_LOGIC_VECTOR(7 downto 0);
       PCWrite:				in STD_LOGIC;
		 RegWrite: 				in STD_LOGIC;
		 MemWrite:				in STD_LOGIC;
		 IRWrite:				in STD_LOGIC;
		 AdrSrc:					in STD_LOGIC;
		 decode_state: 		in STD_LOGIC;
		 ResultSrc:				in STD_LOGIC_VECTOR(1 downto 0);
		 ALUSrcA:				in STD_LOGIC;
		 ALUSrcB:				in STD_LOGIC_VECTOR(1 downto 0);
		 ImmSrc:					in STD_LOGIC_VECTOR(1 downto 0);
		 RegSrc:					in STD_LOGIC_VECTOR(1 downto 0);
		 ALUControl:			in STD_LOGIC_VECTOR(2 downto 0);
		 sh:						in STD_LOGIC_VECTOR(1 downto 0);
		 shamt5:					in STD_LOGIC_VECTOR(4 downto 0);
		 
		 Instr:					out STD_LOGIC_VECTOR(31 downto 0);
		 ALUFlags:				out STD_LOGIC_VECTOR(3 downto 0);
		 PC:						out STD_LOGIC_VECTOR(8 downto 0);
		 ALUResult:				out STD_LOGIC_VECTOR(31 downto 0);
		 WriteData:				out STD_LOGIC_VECTOR(31 downto 0);
		 ReadData:				out STD_LOGIC_VECTOR(31 downto 0));
end component;

	-- Signals needed to make connections between the datapath and controller
	-- controller inputs
	signal Instr : std_logic_vector(31 downto 0);
	signal Cond : std_logic_vector(3 downto 0);
	signal Op : std_logic_vector(1 downto 0);
	signal Funct : std_logic_vector(5 downto 0);
	signal Rd : std_logic_vector(3 downto 0);
	signal Src12 : std_logic_vector(11 downto 0);
	signal Flags : std_logic_vector(3 downto 0);
	
	--controller outputs
	signal PCWrite : std_logic;
	signal RegWrite : std_logic;
	signal MemWrite : std_logic;
	signal IRWrite : std_logic;
	signal AdrSrc : std_logic;
	signal decode_state : std_logic;
	signal ResultSrc : std_logic_vector(1 downto 0);
	signal ALUSrcA : std_logic;
	signal ALUSrcB : std_logic_vector(1 downto 0);
	signal ImmSrc : std_logic_vector(1 downto 0);
	signal RegSrc : std_logic_vector(1 downto 0);
	signal ALUControl : std_logic_vector(2 downto 0);
	signal sh: std_logic_vector(1 downto 0);
	signal shamt5: std_logic_vector(4 downto 0);
	
	--datapath registers
	signal ALUResult : std_logic_vector(31 downto 0);
	signal WriteData : std_logic_vector(31 downto 0);
	signal PC : std_logic_vector(8 downto 0);
	signal ReadData : std_logic_Vector(31 downto 0);

begin
	PCOut <= PC(7 downto 0);
	InstrOut <= Instr(27 downto 20);
	ReadDataOut <= ReadData(7 downto 0); 
	
	-- Break out important data from instr
	Cond <= Instr(31 downto 28);
	Op <= Instr(27 downto 26);
	Funct <= Instr(25 downto 20);
	Rd <= Instr(15 downto 12);
	Src12 <= Instr(11 downto 0);

	-- Instantiate the Controller for the ARM Processor
	Inst_controller: controller PORT MAP(
		clk => clk, reset=>reset,
		Cond=>Cond, ALUFlags=>Flags, Op=>Op, Funct=>Funct, Rd=>Rd,
		Src12=>Src12(11 downto 4), en_ARM=>en_ARM,
		
		PCWrite=>PCWrite, RegWrite=>RegWrite, MemWrite=>MemWrite,
		
		IRWrite=>IRWrite, AdrSrc=>AdrSrc, decode_state=>decode_state,
		ResultSrc=>ResultSrc, ALUSrcA=>ALUSrcA,
		ALUSrcB=>ALUSrcB, ImmSrc=>ImmSrc, RegSrc=>RegSrc, ALUControl=>ALUControl, sh=>sh,
		shamt5=>shamt5
	);

	-- Instantiate the Datapath for the ARM Processor
	Inst_datapath: datapath PORT MAP(
		clk => clk, reset => reset, en_ARM => en_ARM, SWITCH=>SWITCH,
		RegWrite=>RegWrite, PCWrite=>PCWrite, MemWrite=>MemWrite, IRWrite=>IRWrite, 
		AdrSrc=>AdrSrc, decode_state=>decode_state,
		ResultSrc=>ResultSrc, ALUSrcA=>ALUSrcA, ALUSrcB=>ALUSrcB, ImmSrc=>ImmSrc,
		RegSrc=>RegSrc, ALUControl=>ALUControl, sh=>sh, shamt5=>shamt5,
		
		Instr=>Instr, ALUFlags=>Flags, 
		PC=>PC, ALUResult=>ALUResult, WriteData=>WriteData, ReadData=>ReadData
	);

end Behavioral;


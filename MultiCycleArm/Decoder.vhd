----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 Carl Betcher
-- 
-- Create Date:    22:20:32 11/16/2016 
-- Design Name:	 ARM Processor Decoder 
-- Module Name:    Decoder - Behavioral 
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

entity Decoder is
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  Op : in  STD_LOGIC_VECTOR (1 downto 0);
           Funct : in  STD_LOGIC_VECTOR (5 downto 0);
           Rd : in  STD_LOGIC_VECTOR (3 downto 0);
			  Src12 : in STD_LOGIC_VECTOR(11 downto 4);
			  en_ARM : in STD_LOGIC;
			  FlagW : out STD_LOGIC_VECTOR(1 downto 0);
			  PCS : out STD_LOGIC;
			  NextPC : out STD_LOGIC;
			  RegW : out STD_LOGIC;
			  MemW : out STD_LOGIC;
			  IRWrite : out STD_LOGIC;
			  AdrSrc : out STD_LOGIC;
			  decode_state: out STD_LOGIC;
			  ResultSrc : out STD_LOGIC_VECTOR(1 downto 0);
			  ALUSrcA : out STD_LOGIC;
			  ALUSrcB : out STD_LOGIC_VECTOR(1 downto 0);
			  ImmSrc : out STD_LOGIC_VECTOR(1 downto 0);
			  RegSrc : out STD_LOGIC_VECTOR(1 downto 0);
			  ALUControl : out STD_LOGIC_VECTOR(2 downto 0);
			  sh : out STD_LOGIC_VECTOR(1 downto 0);
			  shamt5 : out STD_LOGIC_VECTOR(4 downto 0));
end Decoder;

architecture Behavioral of Decoder is

	type state_type is (Fetch, Decode, 
							  MemAdr, ExecuteR, ExecuteI, Branch_state,
							  MemRead, MemWrite, ALUWB,
							  MemWB);

	alias cmd : std_logic_vector(3 downto 0) 
									is Funct(4 downto 1); -- Instruction Command
																 -- ADD: cmd="0100"
																 -- SUB: cmd="0010"
	alias I   : std_logic is Funct(5); -- I-bit = '0' --> Src2 is a register
												  --       = '1' --> Src2 is an immediate
	alias S   : std_logic is Funct(0); -- S-bit = '1' --> set condition flags
	
	
	signal Controls  : std_logic_vector(9 downto 0);
	
	signal ALUDecOp : std_logic_vector(5 downto 0);
	
	signal ShiftDecOp : std_logic_vector(3 downto 0);

	signal RegWsig : std_logic;
	signal Branch : std_logic;
	signal ALUOp : std_logic;
	signal mulsig : std_logic;
	
	signal state : state_type := Fetch;
	signal next_state : state_type := Fetch;

begin

	-- PC LOGIC
	-- PCS = 1 if PC is written by an instruction or branch (B)
	PCS <= '1' when (Rd = x"F" and RegWsig = '1') or Branch = '1' else '0';
	
	--RegSrc control
	with Op select
		RegSrc <= "01" when "10",
					 "10" when "01",
					 "00" when others;
	
	-- ImmSrc control
	ImmSrc <= Op;
	
	RegW <= RegWsig; -- RegW output

	-- ALU DECODER
	ALUDecOp <= ALUOp & Funct(4 downto 1) & Funct(0);
	
	-- ALUControl sets the operation to be performed by ALU
--	with ALUDecOp select
--	ALUControl <=  "000" when "101000" | "101001",  					-- ADD
--						"001" when "100100" | "100101" | "110101",  		-- SUB/CMP
--						"010" when "100000" | "100001",  					-- AND
--						"011" when "111000" | "111001",  					-- ORR
--						"100" when "100010" | "100011",						-- EOR
--						"101" when "111110" | "111111",						-- MVN
--						"110" when "100000",										-- MUL
--						"111" when "111010" | "111011",						-- MOV
--						"000" when others;  -- Not DP
	
	mulsig <= '1' when Src12(7 downto 4) = "1001" else '0';
	process(ALUOp, cmd, mulsig) begin
		case ALUOp & cmd is
			when "10100"=> -- ADD
				ALUControl <= "000";
			when "10010"=> -- SUB
				ALUControl <= "001";
			when "11010"=> -- CMP
				ALUControl <= "001";
			when "11100"=> -- ORR
				ALUControl <= "011";
			when "10001"=> -- EOR
				ALUControl <= "100";
			when "11111"=> -- MVN
				ALUControl <= "101";
			when "11101"=> -- MOV
				ALUControl <= "111";
			when "10000"=>
				if mulsig = '1' then
					ALUControl <= "110"; -- MUL
				else
					ALUControl <= "010"; -- AND
				end if;
			when others=>
				ALUControl <= "000";
			end case;
	end process;

	-- FlagW: Flag Write Signal
	-- Asserted when ALUFlags should be saved
	-- FlagW(0) = '1' --> save NZ flags (ALUFlags(3:2))
	-- FlagW(1) = '1' --> save CV flags (ALUFlags(1:0))
	with ALUDecOp select								
	FlagW <=  "00" when "101000",  -- ADD     
				 "11" when "101001",  -- ADD     
				 "00" when "100100",  -- SUB     
				 "11" when "100101",  -- SUB
				 "11" when "110101",  -- CMP
				 "00" when "100000",  -- AND
				 "10" when "100001",  -- AND
				 "00" when "111000",  -- ORR
				 "10" when "111001",  -- ORR
				 "00" when others;    -- Not DP
	
	
	ShiftDecOp <= Op & I & Src12(4);
	
	-- TODO: This does NOT  implement register shifted register properly
	with ShiftDecOp select
	shamt5 <= '0' & Src12(11 downto 8) when "0010" | "0011",
				 Src12(11 downto 7) when "0000" | "1100",
				 (others=>'0') when others;
	
	with ShiftDecOp select
	sh <= Src12(6 downto 5) when "0000" | "1100",
			"11" when "0010" | "0011",
			"00" when others;
				 
	process(state, Op, Funct, en_ARM) begin -- state machine
	RegWsig		 <= '0';
	MemW			 <= '0';
	IRWrite		 <= '0';
	AdrSrc 		 <= '0';
	decode_state <= '0';
	AluSrcA 		 <= '1';
	AluSrcB 		 <= "10";
	ALUOp 		 <= '0';
	ResultSrc	 <= "10";
	NextPC 		 <= '0';
	Branch		 <= '0';
	
	case state is
		when Fetch=>
			next_state <= Decode;
			IRWrite <= '1';
			NextPC <= '1';
		
		when Decode=>
			decode_state <= '1';
			AluSrcA <= '1';
			AluSrcB <= "10";
			ALUOp <= '0';
			ResultSrc <= "10";
			if en_ARM = '0' then
				next_state <= Decode;
			elsif Op = "01" then
				next_state <= MemAdr;
			elsif Op = "00" and I = '0' then
				next_state <= ExecuteR;
			elsif Op = "00" and I = '1' then
				next_state <= ExecuteI;
			else
				next_state <= Branch_state;
			end if;
		
		when MemAdr=>
			AluSrcA <= '0';
			AluSrcB <= "01";
			ALUOp <= '0';
			
			if S = '1' then
				next_state <= MemRead;
			else
				next_state <= MemWrite;
			end if;
		
		when ExecuteR=>
			AluSrcA <= '0';
			AluSrcB <= "00";
			ALUOp <= '1';
			next_state <= ALUWB;
		
		when ExecuteI=>
			AluSrcA <= '0';
			AluSrcB <= "01";
			ALUOp <= '1';
			next_state <= ALUWB;
		
		when Branch_state=>
			AluSrcA <= '0';
			AluSrcB <= "01";
			ALUOp <= '0';
			ResultSrc <= "10";
			Branch <= '0';
			next_state <= Fetch;
		
		when MemRead=>
			ResultSrc <= "00";
			AdrSrc <= '1';
			next_state <= MemWB;
		
		when MemWrite=>
			ResultSrc <= "00";
			AdrSrc <= '1';
			MemW <= '1';
			next_state <= Fetch;
		
		when ALUWB=>
			ResultSrc <= "00";
			if cmd = "1010" then
				RegWsig <= '0';
			else
				RegWsig <= '1';
			end if;
			next_state <= Fetch;
		
		when MemWB=>
			ResultSrc <= "01";
			RegWsig <= '1';
			next_state <= Fetch;
	end case;
	end process;
	
	process(clk, next_state) begin -- FSM transition
		if rising_edge(clk) then
			if reset = '1' then
				state <= Fetch;
			else
				state <= next_state;
			end if;
		end if;
	end process;

end Behavioral;


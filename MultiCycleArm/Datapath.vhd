----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer(s): 	 Carl Betcher
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 	 ARM Processor Datapath
-- Module Name:    Datapath - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity datapath is  
  port(clk, reset, en_ARM: in STD_LOGIC;
		 SWITCH:					in STD_LOGIC_VECTOR(7 downto 0);
       PCWrite:				in STD_LOGIC;
		 RegWrite: 				in STD_LOGIC;
		 MemWrite:				in STD_LOGIC;
		 IRWrite:				in STD_LOGIC;
		 AdrSrc:					in STD_LOGIC;
		 decode_state:			in STD_LOGIC;
		 ResultSrc:				in STD_LOGIC_VECTOR(1 downto 0);
		 ALUSrcA:				in STD_LOGIC;
		 ALUSrcB:				in STD_LOGIC_VECTOR(1 downto 0);
		 ImmSrc:					in STD_LOGIC_VECTOR(1 downto 0);
		 RegSrc:					in STD_LOGIC_VECTOR(1 downto 0);
		 ALUControl:			in STD_LOGIC_VECTOR(2 downto 0);
		 sh:						in STD_LOGIC_VECTOR(1 downto 0);
		 shamt5:					in STD_LOGIC_VECTOR(4 downto 0);
		 
		 Instr:					out STD_LOGIC_VECTOR(31 downto 0);
		 InstrVol:				out STD_LOGIC_VECTOR(31 downto 0);
		 ALUFlags:				out STD_LOGIC_VECTOR(3 downto 0);
		 PC:						out STD_LOGIC_VECTOR(8 downto 0);
		 ALUResult:				out STD_LOGIC_VECTOR(31 downto 0);
		 WriteData:				out STD_LOGIC_VECTOR(31 downto 0);
		 ReadData:				out STD_LOGIC_VECTOR(31 downto 0));
end datapath;

architecture Behavioral of Datapath is

	COMPONENT Memory is
	Generic ( data_width : positive := 32; 
             addr_width : positive := 9);
				 
	Port (clk : in std_logic;
			WE : in std_logic;
			A : in std_logic_vector(addr_width - 1 downto 0);
			WD : in std_logic_vector(data_width - 1 downto 0);
			RD : out std_logic_vector(data_width - 1 downto 0));
	end COMPONENT;
 
	COMPONENT Register_File
	GENERIC (word_size : natural := 32;
				addr_size : natural := 4 );
	PORT(
		clk : IN std_logic;
		WE3 : IN std_logic;
		A1 : IN std_logic_vector(3 downto 0);
		A2 : IN std_logic_vector(3 downto 0);
		A3 : IN std_logic_vector(3 downto 0);
		WD3 : IN std_logic_vector(31 downto 0);
		R15 : IN std_logic_vector(31 downto 0);          
		RD1 : OUT std_logic_vector(31 downto 0);
		RD2 : OUT std_logic_vector(31 downto 0));
	END COMPONENT;

	COMPONENT ALU
	Generic (data_size : positive := 32);
	port ( A 			: in std_logic_vector(data_size - 1 downto 0);
			 B 			: in std_logic_vector(data_size - 1 downto 0);
			 ALUControl : in std_logic_vector(2 downto 0);
			 result 		: out std_logic_vector(data_size - 1 downto 0);
			 ALUFlags 	: out std_logic_vector(3 downto 0));
	END COMPONENT;
	
	component shifter is
    Port ( D_in : in  STD_LOGIC_VECTOR (31 downto 0);
           shamt5 : in  STD_LOGIC_VECTOR (4 downto 0);
           sh : in  STD_LOGIC_VECTOR (1 downto 0);
           D_out : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
	
	--PC
	signal PC_int: std_logic_vector(8 downto 0) := (others=>'0');
	
	--Instr/Data Memory
	signal Adr : std_logic_vector(8 downto 0);
	signal A_int : std_logic_vector(8 downto 0);
	signal RDsig : std_logic_vector(31 downto 0);
	signal Instr_int : std_logic_vector(31 downto 0);
	signal InstrVol_int : std_logic_vector(31 downto 0); -- Volatile instruction. (doesn't check IRWrite)
	signal Data : std_logic_vector(31 downto 0);
	
	--Register File
	signal RA1mux : std_logic_vector(3 downto 0);
	signal RA2mux : std_logic_vector(3 downto 0);
	signal RD1sig : std_logic_vector(31 downto 0);
	signal RD2sig : std_logic_vector(31 downto 0);
	signal A : std_logic_vector(31 downto 0);
	signal WriteDataSig : std_logic_vector(31 downto 0);
	
	--ALU
	signal SrcA : std_logic_vector(31 downto 0);
	signal SrcB : std_logic_vector(31 downto 0);
	signal ALUResult_int : std_logic_vector(31 downto 0);
	signal ALUOut : std_logic_vector(31 downto 0);
	signal Result : std_logic_vector(31 downto 0);
	
	--Immediate signals
	signal ExtImm : std_logic_vector(31 downto 0);
	signal ShiftImm: std_logic_vector(31 downto 0);
	
begin
	--send internal signals out
	PC <= PC_int;
	Instr <= Instr_int;
	InstrVol <= InstrVol_int;
	WriteData <= WriteDataSig;
	ReadData <= Data;
	ALUResult <= ALUResult_int;
	
	--instr/data mem muxes
	Adr <= std_logic_vector(resize(unsigned(SWITCH), Adr'length))
						when en_ARM = '0' and reset = '0' and decode_state = '1'
						else "00" & PC_int(8 downto 2) when AdrSrc = '0'
						else Result(10 downto 2);
	
	--Register file muxes
	RA1mux <= Instr_int(19 downto 16) when RegSrc(0)='0' else x"F";
	RA2mux <= Instr_int(3 downto 0) when RegSrc(1)='0' else Instr_int(15 downto 12);
	
	--ALU Muxes
	SrcA <= A when ALUSrcA = '0' else x"00000" & "000" & PC_int;
	
	with ALUSrcB select
		SrcB <= WriteDataSig when "00",
				  ShiftImm when "01",
				  x"00000004" when others;
	
	--zero-extended immediate mux
	with ImmSrc select
		ExtImm <= (31 downto 26 => Instr_int(23)) & Instr_int(23 downto 0) & "00" when "10",
					 x"000000" & Instr_int(7 downto 0) when "00",
					 x"00000" & Instr_int(11 downto 0) when others;
	
	--Result mux
	with ResultSrc select
		Result <= ALUOut when "00",
					 Data when "01",
					 ALUResult_int when others;
	
	process(clk, reset, Result) begin --PC control
		if rising_edge(clk) then
			if reset = '1' then
				PC_int <= (others=>'0');
			elsif PCWrite = '1' then
				PC_int <= Result(8 downto 0);
			end if;
		end if;
	end process;
	
	process(clk, reset, RDsig, IRWrite) begin --Fetch instr
		if rising_edge(clk) then
			if reset = '1' then
				Instr_int <= (others=>'0');
			elsif IRWrite = '1' then
				Instr_int <= RDsig;
			end if;
		end if;
	end process;
	
	process(clk, reset, RDsig, IRWrite) begin --Fetch instr
		if rising_edge(clk) then
			if reset = '1' then
				InstrVol_int <= (others=>'0');
			else
				InstrVol_int <= RDsig;
			end if;
		end if;
	end process;
	
	process(clk, reset, RD1sig, RD2sig) begin --clock A and writedatasig
		if rising_edge(clk) then
			if reset = '1' then
				A <= (others=>'0');
				WriteDataSig <= (others=>'0');
			else
				A <= RD1sig;
				WriteDataSig <= RD2sig;
			end if;
		end if;
	end process;
	
	process(clk, reset, ALUResult_int) begin --clock ALUOut
		if rising_edge(clk) then
			if reset = '1' then
				ALUOut <= (others=>'0');
			else
				ALUOut <= ALUResult_int;
			end if;
		end if;
	end process;
	
	process(clk, reset, RDsig) begin --clock Data
		if rising_edge(clk) then
			if reset = '1' then
				Data <= (others=>'0');
			else
				Data <= RDsig;
			end if;
		end if;
	end process;
	
	A_int <= Adr;
	
	mem: Memory PORT MAP(
		clk=>clk,
		A=>A_int,
		WE=>MemWrite, WD=>WriteDataSig,
		RD=>RDsig);
	
	regfile: Register_File PORT MAP(
		clk=>clk,
		WE3=>RegWrite,
		A1=>RA1mux, A2=>RA2mux, A3=>Instr_int(15 downto 12),
		WD3=>Result, R15=>Result,
		RD1=>RD1sig, RD2=>RD2sig);
	
	i_alu : ALU PORT MAP(
		A=>SrcA, B=>SrcB,
		ALUControl=>ALUControl,
		Result=>ALUResult_int, ALUFlags=>ALUFlags);
	
	i_shifter : Shifter PORT MAP(
		D_in=>ExtImm,
		sh=>sh, shamt5=>shamt5,
		D_out=>ShiftImm);
end Behavioral;


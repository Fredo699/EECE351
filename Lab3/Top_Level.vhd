----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 Fred Frey & Caleb Wagoner
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TopLevel is
    Port ( Clk : in STD_LOGIC;
			  Switch : in  STD_LOGIC_VECTOR (7 downto 0);
			  DIR_DOWN : in  STD_LOGIC;
			  DIR_LEFT : in std_logic;
			  DIR_RIGHT : in std_logic;
			  SSEG_P : out std_logic;
			  SSEG_AN: out std_logic_vector(4 downto 0);
			  SSEG_OUT: out std_logic_vector(6 downto 0);
			  VGA_RED: out std_logic_vector(3 downto 0);
           LED : out  STD_LOGIC_VECTOR (7 downto 0) );
end TopLevel;

architecture Behavioral of TopLevel is
	-- Insert your Seq_Detect component here:
	component Reg4wLoad is
		port ( clk : in std_logic;
				 I : in std_logic_vector;
				 load : in std_logic;
				 Q : out std_logic_vector);
	end component;
	
	component HEXon7segDisp is
		Port ( hex_data_in0 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in1 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in2 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in3 : in  STD_LOGIC_VECTOR (3 downto 0);
           dp_in : in  STD_LOGIC_VECTOR (2 downto 0);
           seg_out : out  STD_LOGIC_VECTOR (6 downto 0);
           an_out : out  STD_LOGIC_VECTOR (3 downto 0);
           dp_out : out  STD_LOGIC;
           clk : in  STD_LOGIC);
	end component;
	
	signal reg1sig : std_logic_vector(3 downto 0);
	signal reg2sig : std_logic_vector(3 downto 0);
	signal reg3sig : std_logic_vector(3 downto 0);
	signal reg4sig : std_logic_vector(3 downto 0);	
	signal reg5sig : std_logic_vector(2 downto 0);

begin

	Reg1 : Reg4wLoad
		port map(clk=>clk, I=>Switch(7 downto 4), load=>DIR_LEFT, Q=>reg1sig);
	Reg2 : Reg4wLoad
		port map(clk=>clk, I=>Switch(3 downto 0), load=>DIR_LEFT, Q=>reg2sig);
	Reg3 : Reg4wLoad
		port map(clk=>clk, I=>Switch(7 downto 4), load=>DIR_RIGHT, Q=>reg3sig);
	Reg4 : Reg4wLoad
		port map(clk=>clk, I=>Switch(3 downto 0), load=>DIR_RIGHT, Q=>reg4sig);
	Reg5 : Reg4wLoad
		port map(clk=>clk, I=>Switch(2 downto 0), load=>DIR_DOWN, Q=>reg5sig);
	
	HexDisp : HEXon7segDisp
		port map(clk=>clk, dp_in=>reg5sig, hex_data_in0=>reg1sig, hex_data_in1=>reg2sig,
					hex_data_in2=>reg3sig, hex_data_in3=>reg4sig, an_out=>SSEG_AN(3 downto 0), seg_out=>sseg_out, 
					dp_out=>SSEG_P);
	
	LED <= SWITCH;
	SSEG_AN(4) <= '1';
	

end Behavioral;

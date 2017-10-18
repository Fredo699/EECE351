----------------------------------------------------------------------------------
-- Company Name:   Binghamton University
-- Engineer(s):    Carl Betcher
-- Create Date:    10/18/2016 
-- Module Name:    TopLevel - Behavioral 
-- Project Name:   Lab6
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TopLevel is
    Port ( Osc_Clk : in STD_LOGIC;
			  Switch : in  STD_LOGIC_VECTOR (7 downto 5);
           LED : out  STD_LOGIC_VECTOR (7 downto 0);
			  Seg7_SEG : out STD_LOGIC_VECTOR (6 downto 0); 
			  Seg7_DP  : out STD_LOGIC; 
			  Seg7_AN  : out STD_LOGIC_VECTOR (4 downto 0);
			  SPI_CS : out STD_LOGIC; 
			  SPI_SCLK : out STD_LOGIC;
			  SPI_MOSI : out STD_LOGIC; 
			  SPI_MISO : in STD_LOGIC 
			  );
end TopLevel;

architecture Behavioral of TopLevel is

	COMPONENT DivideByN
	Generic ( N : positive := 64 );
	PORT(
		clk_in : IN std_logic;  
		clk_out : OUT std_logic
		);
	END COMPONENT;

	COMPONENT ADC_Interface
	PORT(
		clk : IN std_logic;
		ADC_number : IN std_logic_vector(2 downto 0);
		Sample : IN std_logic;
		SPI_CS : OUT std_logic;
		SPI_SCLK : out STD_LOGIC;
		SPI_MOSI : OUT std_logic;
		SPI_MISO : IN std_logic;
		ADC_data_out : OUT std_logic_vector(11 downto 0)
		);
	END COMPONENT;

	-- Declare HEXon7segDisp component
	COMPONENT HEXon7segDisp
	PORT(
		hex_data_in0 : IN std_logic_vector(3 downto 0);
		hex_data_in1 : IN std_logic_vector(3 downto 0);
		hex_data_in2 : IN std_logic_vector(3 downto 0);
		hex_data_in3 : IN std_logic_vector(3 downto 0);
		dp_in : IN std_logic_vector(2 downto 0);
		clk : IN std_logic;          
		seg_out : OUT std_logic_vector(6 downto 0);
		an_out : OUT std_logic_vector(3 downto 0);
		dp_out : OUT std_logic
		);
	END COMPONENT;

	-- Signals for Hex Display
	signal HexDisp : std_logic_vector(15 downto 0) := x"0000";
	
	-- Signals for ADC Interface
	signal Sample 	: std_logic; 	  -- sets sample rate of ADC
	signal ADC_data_out : std_logic_vector(11 downto 0);
	
begin

	-- Clock divider to reduce 16 MHz to 0.5 MHz to set ADC sample rate
	DivideByN_1: DivideByN PORT MAP(
		clk_in => Osc_Clk,
		clk_out => Sample 
	);

	-- ADC Interface
	ADC_Interface1: ADC_Interface PORT MAP(
		clk => Osc_Clk,
		ADC_number => Switch(7 downto 5),
		Sample => Sample,
		SPI_SCLK => SPI_SCLK,
		SPI_CS => SPI_CS,
		SPI_MOSI => SPI_MOSI,
		SPI_MISO => SPI_MISO,
		ADC_data_out => ADC_data_out
	);

	-- Display ADC Output on 7-Segment Disply
	HexDisp <= "0000" & ADC_data_out;

	-- Instantiate Hex to 7-segment conversion module
	HEXon7segDisp1: HEXon7segDisp PORT MAP(
		hex_data_in0 => HexDisp(15 downto 12),
		hex_data_in1 => HexDisp(11 downto 8),
		hex_data_in2 => HexDisp(7 downto 4),
		hex_data_in3 => HexDisp(3 downto 0),
		dp_in => "000",  -- no decimal point
		seg_out => Seg7_SEG,
		an_out => Seg7_AN(3 downto 0),
		dp_out => Seg7_DP,
		clk => Osc_Clk
	);
	
	Seg7_AN(4) <= '1';
		
	-- Misc connections
	LED(7 downto 0) <= "00000000";	
		
end Behavioral;

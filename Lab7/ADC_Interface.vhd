----------------------------------------------------------------------------------
-- Company Name:   Binghamton University
-- Engineer(s):    
-- Create Date:    10/18/2016 
-- Module Name:    ADC_Interface - Behavioral 
-- Project Name:   Lab6
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADC_Interface is
    Port ( clk : in  STD_LOGIC;
			  ADC_number : in std_logic_vector(2 downto 0);
           Sample : in  STD_LOGIC;
           SPI_CS : out  STD_LOGIC;
           SPI_SCLK : out  STD_LOGIC;
           SPI_MOSI : out  STD_LOGIC;
           SPI_MISO : in  STD_LOGIC;
           ADC_data_out : out  STD_LOGIC_VECTOR (11 downto 0));
end ADC_Interface;

architecture Behavioral of ADC_Interface is

component Datapath is
    Port ( clk : in STD_LOGIC;
           Inc_count : in  STD_LOGIC;
           ADC_Number : in  STD_LOGIC_VECTOR(2 downto 0);
           ld_ctrl : in  STD_LOGIC;
           ld_mosi : in  STD_LOGIC;
			  ld_data : in STD_LOGIC;
			  ld_adc : in STD_LOGIC;
           shift_ctrl : in  STD_LOGIC;
			  rst_count : in STD_LOGIC;
			  SPI_MISO : in STD_LOGIC;
			  SPI_MOSI : out  STD_LOGIC := '0';
           eq16 : out  STD_LOGIC;
           eq1 : out  STD_LOGIC;
           eq4 : out  STD_LOGIC;
			  ADC_data_out : out STD_LOGIC_VECTOR(11 downto 0));
end component;

component Controller is
	 Port ( clk : in  STD_LOGIC;
           eq16 : in  STD_LOGIC;
           eq1 : in  STD_LOGIC;
           eq4 : in  STD_LOGIC;
			  sample : in STD_LOGIC;
			  spi_cs : out STD_LOGIC;
			  spi_sclk : out STD_LOGIC;
           inc_count : out  STD_LOGIC;
           rst_count : out  STD_LOGIC;
           ld_ctrl : out  STD_LOGIC;
           ld_mosi : out  STD_LOGIC;
			  ld_adc : out STD_LOGIC;
			  ld_data : out STD_LOGIC;
           shift_ctrl : out  STD_LOGIC);
end component;

signal eq16, eq1, eq4, ld_ctrl, ld_data, ld_adc, ld_mosi, rst_count, shift_ctrl, inc_count : std_logic;

begin

	dp : Datapath
		port map(clk=>clk, inc_count=>inc_count, ADC_Number=>ADC_number, ld_ctrl=>ld_ctrl, ld_mosi=>ld_mosi, ld_data=>ld_data, ld_adc=>ld_adc,
					shift_ctrl=>shift_ctrl, rst_count=>rst_count, SPI_MISO=>SPI_MISO, SPI_MOSI=>SPI_MOSI, eq16=>eq16, eq1=>eq1, eq4=>eq4, 
					ADC_data_out=>ADC_data_out);
					
	ctrl : Controller
		port map(clk=>clk, eq16=>eq16, eq1=>eq1, eq4=>eq4, sample=>sample, spi_cs=>spi_cs, spi_sclk=>spi_sclk, inc_count=>inc_count,
					rst_count=>rst_count, ld_mosi=>ld_mosi, ld_adc=>ld_adc, ld_data=>ld_data, ld_ctrl=>ld_ctrl, shift_ctrl=>shift_ctrl);

end Behavioral;
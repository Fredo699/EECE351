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

-- #############################################################
-- ########## Your Component and Signal Declarations ###########
-- #############################################################

begin

-- #############################################################
-- ########## Your Component Instantiations with ###############
-- ################## Signal Connections #######################
-- #############################################################

end Behavioral;
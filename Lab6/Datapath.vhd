----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:38:36 10/18/2017 
-- Design Name: 
-- Module Name:    Datapath - Behavioral 
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

entity Datapath is
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
end Datapath;

architecture Behavioral of Datapath is

signal data_reg : std_logic_vector(11 downto 0);
signal counter : unsigned(4 downto 0) := to_unsigned(0, 5);
signal ctrl : std_logic_vector( 3 downto 0) := (others=>'0');

begin
	
	process (clk) begin
		if rising_edge(clk) then
			if rst_count = '1' then
				counter <= to_unsigned(0, 5);
			elsif inc_count = '1' then
				counter <= counter + 1;
			end if;
			
			if ld_mosi = '1' then
				SPI_MOSI <= ctrl(3);
			end if;
			
			if ld_ctrl = '1' then
				if shift_ctrl = '0' then
					ctrl <= '0' & ADC_Number;
				else
					ctrl <= ctrl(2 downto 0) & '0';
				end if;
			end if;
			
			if ld_data = '1' then	
				data_reg <= data_reg(10 downto 0) & SPI_MISO;
			end if;
			
			if ld_adc = '1' then
				ADC_data_out <= data_reg;
			end if;
			
		end if;
	end process;
	
	process (counter) begin
		eq1 <= '0';
		eq4 <= '0';
		eq16 <= '0';
		if counter = 16 then
			eq16 <= '1';
		elsif counter = 1 then
			eq1 <= '1';
		elsif counter = 4 then
			eq4 <= '1';
		end if;
	end process;
end Behavioral;


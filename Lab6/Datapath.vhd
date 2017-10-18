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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Datapath is
    Port ( clk : in STD_LOGIC;
			  MISO : in  STD_LOGIC;
           Inc_count : in  STD_LOGIC;
           adc_number : in  STD_LOGIC;
           ld_control : in  STD_LOGIC;
           ld_mosi : in  STD_LOGIC;
           shift_ctrl : in  STD_LOGIC;
			  rst_count : in STD_LOGIC;
			  MOSI : out  STD_LOGIC;
           eq0 : out  STD_LOGIC;
           eq1 : out  STD_LOGIC;
           eq4 : out  STD_LOGIC);
end Datapath;

architecture Behavioral of Datapath is

signal counter : unsigned(3 downto 0) := 0;
signal ctrl : std_logic_vector( 3 downto 0) := (others=>'0');
signal spi_mosi : std_logic := '0';

begin
	process (clk) begin
		if rising_edge(clk) then
			if rst_count = '1' then
				counter <= 0;
			elsif inc_counter = '1' then
				counter <= counter + 1; 
			end if;
		end if;
	end process;
	
	process (counter) begin
		if counter = 0 then
			eq0 <= '1';
			eq1 <= '0';
			eq4 <= '0';
		elsif counter = 1 then
			eq0 <= '0';
			eq1 <= '1';
			eq4 <= '0';
		elsif counter = 4 then
			eq0 <= '0';
			eq1 <= '0';
			eq4 <= '1';
		else 
			eq0 <= '0';
			eq1 <= '0';
			eq4 <= '0';
		end if;
	end process;

end Behavioral;


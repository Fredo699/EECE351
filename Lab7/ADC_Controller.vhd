----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:09:43 10/23/2017 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
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

entity Controller is
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
end Controller;

architecture Behavioral of Controller is

type shift_state_type is (clear, wait_shift, count);
type control_state_type is (load_control, shift_control, wait_control);
type data_state_type is (load_data, wait_data, shift_data);

signal shift_state : shift_state_type := clear;
signal control_state : control_state_type := load_control;
signal data_state : data_state_type := load_data;

signal next_shift : shift_state_type;
signal next_control : control_state_type;
signal next_data : data_state_type;

signal sig_sclk : std_logic := '0';

begin
	SPI_SCLK <= sig_sclk;

	process(clk) begin
		if rising_edge(clk) then
			shift_state <= next_shift;
			control_state <= next_control;
			data_state <= next_data;
		end if;
	end process;
	
	process(shift_state, sample, eq16) begin
		rst_count <= '0';
		inc_count <= '0';
		case shift_state is
			when clear =>
				rst_count <= '1';
				spi_cs <= '1';
				sig_sclk <= '1';
				if sample = '1' then
					next_shift <= wait_shift;
				else
					next_shift <= clear;
				end if;
			when wait_shift =>
				spi_cs <= '0';
				sig_sclk <= '1';
				if eq16 = '0' then
					next_shift <= count;
				else
					next_shift <= clear;
				end if;
			when count =>
				spi_cs <= '0';
				sig_sclk <= '0';
				inc_count <= '1';
				next_shift <= wait_shift;
		end case;
	end process;
	
	process(control_state, eq1, eq4, sig_sclk) begin
		ld_mosi <= '0';
		case control_state is
			when load_control =>
				shift_ctrl <= '0';
				ld_ctrl <= '1';
				if eq1 = '1' and sig_sclk = '0' then
					next_control <= shift_control;
				else
					next_control <= load_control;
				end if;
			when shift_control =>
				shift_ctrl <= '1';
				ld_ctrl <= '1';
				ld_mosi <= '1';
				next_control <= wait_control;
			when wait_control =>
				shift_ctrl <= '0';
				ld_ctrl <= '0';
				if eq4 = '1' then
					next_control <= load_control;
				else
					next_control <= shift_control;
				end if;
		end case;
	end process;
		
	process(data_state, eq4, eq16) begin
		ld_adc <= '0';
		ld_data <= '0';
		case data_state is
			when load_data =>
				ld_adc <= '1';
				if eq4 = '1' then
					next_data <= wait_data;
				else
					next_data <= load_data;
				end if;
			when wait_data =>
				next_data <= shift_data;
			when shift_data =>
				ld_data <= '1';
				if eq16 = '1' then
					next_data <= load_data;
				else
					next_data <= wait_data;
				end if;
		end case;
	end process;

end Behavioral;


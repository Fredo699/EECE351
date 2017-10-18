----------------------------------------------------------------------------------
-- Company:  Binghamton University
-- Engineer: Fred Frey & Caleb Wagoner
-- 
-- Create Date:    12:05:12 10/09/2017 
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
           bt1 : in  STD_LOGIC;
           bt0 : in  STD_LOGIC;
           bt2 : in  STD_LOGIC;
           eq15 : in  STD_LOGIC;
           w_en : out STD_LOGIC;
			  ld_addrs : out STD_LOGIC;
			  ld_sum : out STD_LOGIC;
			  rst_r : out STD_LOGIC;
			  muxsel : out STD_LOGIC);
end Controller;

architecture Behavioral of Controller is

type state_type is (Idle, Ld_addr_reg, Disp_Regfile, Write_data, Init_Sum, Wait1, Sum, Disp_sum);
signal state 		: state_type := Idle;
signal next_state : state_type := Idle;

begin
	process(clk) begin	
		if rising_edge(clk) then
			state <= next_state;
		end if;
	end process;
	
	process(state, bt0, bt1, bt2, eq15) begin
		ld_addrs <= '0';
		w_en <= '0';
		muxsel <= '0';
		rst_r <= '0';
		ld_sum <= '0';
		case state is
			when Idle =>
				if bt0 = '1' then
					next_state <= Ld_addr_reg;
				elsif bt1 = '1' then
					next_state <= Write_data;
				elsif bt2 = '1' then
					next_state <= Init_sum;
				else
					next_state <= Idle;
				end if;
				
			when Ld_addr_reg =>
				ld_addrs <= '1';
				next_state <= Disp_Regfile;
				
			when Write_Data =>
				w_en <= '1';
				next_state <= Disp_Regfile;
				
			when Disp_Regfile =>
				muxsel <= '0';
				ld_addrs <= '0';
				w_en <= '0';
				next_state <= Idle;
				
			when Init_sum =>
				rst_r <= '1';
				next_state <= Wait1;
			
			when Wait1 =>
				ld_sum <= '0';
				rst_r <= '0';
				next_state <= Sum;
			
			when Sum =>
				if eq15 = '1' then
					next_state <= Disp_Sum;
				else
					ld_sum <= '1';
					next_state <= Wait1;
				end if;
			
			when Disp_Sum =>
				muxsel <= '1';
				if bt2 = '1' then
					next_state <= Idle;
				else
					next_state <= Disp_Sum;
				end if;
			when others =>
				next_state <= Idle;
		end case;
	end process;
end Behavioral;


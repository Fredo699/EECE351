----------------------------------------------------------------------------------
-- Company:  Binghamton University
-- Engineer: Fred Frey & Caleb Wagoner
-- 
-- Create Date:    12:08:15 10/09/2017 
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
    Port ( W_en : in  STD_LOGIC;
			  clk : in std_logic;
           rst_r : in  STD_LOGIC;
           muxsel : in  STD_LOGIC;
			  w_addr : in std_logic_vector (3 downto 0);
			  r_addr : in std_logic_vector (3 downto 0);
           w_data : in  STD_LOGIC_VECTOR (7 downto 0);
			  r_data : out std_logic_vector (7 downto 0);
			  ld_addr : in std_logic;
			  sig_sum : in std_logic;
           eq15 : out  STD_LOGIC;
           HexDisp : out  STD_LOGIC_VECTOR (15 downto 0));
end Datapath;

architecture Behavioral of Datapath is

component RegisterFile is
	 Generic (addr_size : natural := 4;
				 word_size : natural := 8);
    Port ( W_addr : in  STD_LOGIC_VECTOR (addr_size - 1 downto 0);
           R_addr : in  STD_LOGIC_VECTOR (addr_size - 1 downto 0);
           W_en : in  STD_LOGIC;
			  clk : in std_logic;
			  W_Data : in std_logic_vector(word_size - 1 downto 0);
           W_Data_out : out  STD_LOGIC_VECTOR (word_size - 1 downto 0);
           R_Data : out  STD_LOGIC_VECTOR (word_size - 1 downto 0));
end component;

signal w_addr_int : std_logic_vector(3 downto 0);
signal r_addr_int : std_logic_vector(3 downto 0);
signal w_dout_int : std_logic_vector(7 downto 0);
signal r_data_int : std_logic_vector(7 downto 0);
signal w_data_int : std_logic_vector(7 downto 0);
signal sum    		: unsigned(15 downto 0);
signal hex_disp : std_logic_vector(15 downto 0);

begin
	r_data <= r_data_int;
	w_data_int <= w_data;
	regfile : RegisterFile
		port map(W_addr=>w_addr_int, w_data=>w_data_int, r_addr=>r_addr_int, clk=>clk, w_en=>w_en,
				   r_data=>r_data_int, w_data_out=>w_dout_int);
	
	process(clk) begin
		if rising_edge(clk) then
			if sig_sum = '1' then
				sum <= sum + unsigned(r_data_int);
				r_addr_int <= std_logic_vector(unsigned(r_addr_int) + 1);
			end if;
		end if;
		
		if r_addr_int = "1111" then
			eq15 <= '1';
		else
			eq15 <= '0';
		end if;
	end process;
	
	process(clk, w_addr, r_addr) begin
		if rising_edge(clk) then
			if ld_addr = '1' then
				w_addr_int <= w_addr;
				r_addr_int <= r_addr;
			end if;
			w_data_int <= w_data;
		end if;
	end process; 
	
	process(clk, w_en) begin
		if rising_edge(clk) then	
			if w_en = '1' then
				regfile(to_integer(unsigned(w_addr_int))) <= W_data;
			end if;
		end if;
	end process;
	
	process(muxsel) begin
		if muxsel = '0' then
			hex_disp(15 downto 8) <= w_dout_int;
			hex_disp(7 downto 0) <= r_data_int;
		else
			hex_disp <= std_logic_vector(sum);
		end if;
	end process;

end Behavioral;


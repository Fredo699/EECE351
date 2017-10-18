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
    Port ( clk : in std_logic;
			  W_en : in  STD_LOGIC;
           rst_r : in STD_LOGIC;
			  muxsel : in std_logic;
			  ld_addrs : in STD_LOGIC;
			  ld_sum   : in STD_LOGIC;
			  Switch : in STD_LOGIC_VECTOR(7 downto 0);
			  raddr, waddr : out std_logic_vector(3 downto 0);
			  eq15 : out std_logic;
			  HexDisp : out std_logic_vector(15 downto 0));
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

signal raddr_reg : std_logic_vector(3 downto 0) := (others=>'0');
signal waddr_reg : std_logic_vector(3 downto 0) := (others=>'0');

signal wdata_reg : std_logic_vector(7 downto 0);
signal rdata_reg : std_logic_vector(7 downto 0);

signal sum_reg : unsigned(15 downto 0);

begin

	raddr <= raddr_reg;
	waddr <= waddr_reg;
	
	regfile : RegisterFile
		port map(W_addr=>waddr_reg, R_addr=>raddr_reg, W_en=>W_en, clk=>clk, W_Data=>Switch, W_Data_out=>wdata_reg,
					r_data=>rdata_reg);

	process(clk) begin
		if rising_edge(clk) then
			if rst_r = '1' then
				sum_reg <= to_unsigned(0, 16);
				raddr_reg <= "0000";
			elsif ld_addrs = '1' then
				waddr_reg <= Switch(7 downto 4);
				raddr_reg <= Switch(3 downto 0);
			elsif ld_sum = '1' then
				sum_reg <= sum_reg + unsigned(rdata_reg);
				raddr_reg <= std_logic_vector(unsigned(raddr_reg) + 1);
			end if;
		end if;
	end process;
	
	process(raddr_reg) begin
		if raddr_reg = "1111" then
			eq15 <= '1';
		else
			eq15 <= '0';
		end if;
	end process;
	
	process(clk, muxsel, rdata_reg, wdata_reg, sum_reg) begin
		if rising_edge(clk) then
			if muxsel = '0' then
				HexDisp <= rdata_reg & wdata_reg;
			else
				HexDisp <= std_logic_vector(sum_reg);
			end if;
		end if;
	end process;

end Behavioral;


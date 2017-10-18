----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer:		
-- 
-- Create Date:    10/11/2014 
-- Design Name:    HLSM for Register File
-- Module Name:    RegFile_HLSM - Behavioral 
-- Project Name:   Lab5
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RegFile_HLSM is
	PORT( clk : STD_LOGIC;
			btn0 : STD_LOGIC;
			btn1 : STD_LOGIC;
			btn2 : STD_LOGIC;
		   Switch : in  STD_LOGIC_VECTOR (7 downto 0);
		   HexDisp : out  STD_LOGIC_VECTOR (15 downto 0);
		   W_Addr : out STD_LOGIC_VECTOR (3 downto 0); 
		   R_Addr : out STD_LOGIC_VECTOR (3 downto 0));
end RegFile_HLSM;

architecture Behavioral of RegFile_HLSM is

	-- Declare datapath component
component Datapath is
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
end component;

	-- Declare controller component
component Controller is
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
end component;

	-- Signals for interconnections between datapath and controller
signal w_en, rst_r, muxsel, ld_addr, ld_sum, eq15, ld_addrs, ld_next : std_logic;
signal r_data, w_data : std_logic_vector(7 downto 0); -- dummies for datapath.
signal w_addr_int, r_addr_int : std_logic_vector(3 downto 0); -- dummies for datapath.
	
begin
	-- Instantiate Datapath Module
	dp : Datapath
		port map(clk=>clk, w_en=>w_en, rst_r=>rst_r, muxsel=>muxsel,
					ld_addrs=>ld_addrs, ld_sum=>ld_sum, Switch=>Switch,
					eq15=>eq15, HexDisp=>HexDisp,
					raddr=>r_addr, waddr=>w_addr);

	
	-- Instantiate Controller Module
	ctrl : controller
		port map(clk=>clk, bt0=>btn0, bt1=>btn1, bt2=>btn2, eq15=>eq15, w_en=>w_en, ld_addrs=>ld_addrs, rst_r=>rst_r,
					muxsel=>muxsel, ld_sum=>ld_sum);
	
end Behavioral;

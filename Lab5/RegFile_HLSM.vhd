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
end component;

	-- Declare controller component
component Controller is
	Port ( clk : in  STD_LOGIC;
           bt1 : in  STD_LOGIC;
           bt0 : in  STD_LOGIC;
           bt2 : in  STD_LOGIC;
           eq15 : in  STD_LOGIC;
           muxsel : out  STD_LOGIC;
           rst_r : out  STD_LOGIC;
			  ld_addr : out STD_LOGIC;
			  sig_sum : out STD_LOGIC;
           w_en : out  STD_LOGIC;
           w_data : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

	-- Signals for interconnections between datapath and controller
signal w_en, rst_r, muxsel, ld_addr, sig_sum, eq15 : std_logic;
signal r_data, w_data : std_logic_vector(7 downto 0);
	
begin

	-- Instantiate Datapath Module
	dp : Datapath
		port map(w_en=>w_en, clk=>clk, rst_r=>rst_r, muxsel=>muxsel, w_addr=>w_addr, r_addr=>r_addr,
					w_data=>switch, r_data=>r_data, ld_addr=>ld_addr, sig_sum=>sig_sum, eq15=>eq15, HexDisp=>HexDisp);
	-- Instantiate Controller Module
	control : Controller
		port map(clk=>clk, bt0=>bt0, bt1=>bt1, bt2=>bt2, eq15=>eq15, muxsel=>muxsel, rst_r=>rst_r, ld_addr=>ld_addr,
					sig_sum=>sig_sum, w_en=>w_en, w_data=>w_data);
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 Fred Frey & Caleb Wagoner
-- 
-- Create Date:    17:40:05 09/02/2012 
-- Design Name: 
-- Module Name:    TopLevel - Behavioral 
-- Project Name:   Lab2 - Sequence Detection FSM
--
-- Revisions:  09/12/2014  Added clock enable input to Seq_Detect for the purpose 
--					  			   of single-stepping the FSM instead of feeding button 
--								   input directly to the clock signal.
--					09/12/2015  Updated debounce circuit to use a long delay so that it 
--									will function properly with the Papilio FPGA board that
--									doesn't have built-in Schmitt-Triggers. Uses generic 
--									DELAY parameter so the delay can be set small for 
--									simulation.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TopLevel is
    Port ( Clk : in STD_LOGIC;
			  Switch : in  STD_LOGIC_VECTOR (0 downto 0);
			  DIR_UP : in  STD_LOGIC;	
           LED : out  STD_LOGIC_VECTOR (7 downto 0) );
end TopLevel;

architecture Behavioral of TopLevel is
	component debounce is 
		Generic ( DELAY : integer := 640000 -- DELAY = 20 mS / clk_period
					 );
		Port ( clk : in  STD_LOGIC;
				 sig_in : in  STD_LOGIC;
				 sig_out : out  STD_LOGIC
				 );
	end component;
	
	-- Insert your Seq_Detect component here:
	component Seq_Detect is
		Port (clk : in STD_LOGIC;
				clk_enable : in STD_LOGIC;
				seq : in STD_LOGIC;
				found : out STD_LOGIC;
				state_out : out STD_LOGIC_VECTOR(4 downto 0));
	end component;
				
	
	signal clk_enable : std_logic;

begin
	-- Debounce the signmal from the momentary switch and produce a pulse
	-- that is one clock period in duration, synchronized with the clock
	Sync_Button: debounce 
						generic map ( DELAY => 640000 ) 
						port map (	sig_in => 	DIR_UP,
													clk    => 	Clk,
													sig_out => 	clk_enable);

	-- Insert Seq_Detect1 Instance
	SeqDetect1 : Seq_Detect
			port map(clk => clk,
						clk_enable => clk_enable,
						seq => SWITCH(0),
						found => LED(7),
						state_out => LED(4 downto 0));
					 
	-- Unused LEDs driven off
	LED(6 downto 5) <= "00";

end Behavioral;

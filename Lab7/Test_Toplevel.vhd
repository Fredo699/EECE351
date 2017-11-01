--------------------------------------------------------------------------------
-- Company Name:  Binghamton University
-- Engineer(s):   Carl Betcher
-- Create Date:   10/25/2016 
-- Module Name:   Test_TopLevel.vhd
-- Project Name:  Lab7
-- VHDL Test Bench Created by ISE for module: TopLevel
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY Test_TopLevel IS
END Test_TopLevel;
 
ARCHITECTURE behavior OF Test_TopLevel IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
	 COMPONENT TopLevel
	 GENERIC (DAC_MSB : integer := 11);
	 PORT(
			  Osc_Clk : in STD_LOGIC;
			  Switch : in  STD_LOGIC_VECTOR (7 downto 4);
			  LED : out  STD_LOGIC_VECTOR (7 downto 0);
			  Seg7_SEG : out STD_LOGIC_VECTOR (6 downto 0); 
			  Seg7_DP  : out STD_LOGIC; 
			  Seg7_AN  : out STD_LOGIC_VECTOR (4 downto 0);
			  SPI_SCLK : out STD_LOGIC;
			  SPI_MISO : in STD_LOGIC; 
			  SPI_MOSI : out STD_LOGIC; 
			  SPI_CS : out STD_LOGIC;
			  Audio : out STD_LOGIC
			);
 	END COMPONENT;

   --Inputs
   signal Osc_Clk : std_logic := '0';
   signal Switch : std_logic_vector(7 downto 4) := (others => '0');
 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal Seg7_SEG : std_logic_vector(6 downto 0);
   signal Seg7_DP : std_logic;
   signal Seg7_AN : std_logic_vector(4 downto 0);
	signal Audio : std_logic;
   --ADC I/O
	signal SPI_SCLK : std_logic;
	signal SPI_MISO : std_logic := '0';
	signal SPI_MOSI : std_logic := '0';
	signal SPI_CS : std_logic;
	-- Clock period definitions
   constant Osc_Clk_period : time := 31.25 ns;
 
	-- Test Data
	type test_vector is record
		Switch   : std_logic_vector(7 downto 4);
		ADC_data : std_logic_vector(11 downto 0);
	end record;

	type test_data_array is array (natural range <>) of test_vector;
	constant test_data : test_data_array :=
		(
			( "1010", x"A5D" ),
			( "0110", x"F0B" ),
			( "1100", x"823" )
		);

BEGIN
	-- InstSeg7_ANtiate the Unit Under Test (UUT)
   uut: TopLevel 
	GENERIC MAP (DAC_MSB => 7)
	PORT MAP (
          Osc_Clk => Osc_Clk,
          Switch => Switch,
          LED => LED,
          Seg7_SEG => Seg7_SEG,
          Seg7_DP => Seg7_DP,
          Seg7_AN => Seg7_AN,
			 SPI_SCLK => SPI_SCLK,
			 SPI_MISO => SPI_MISO,
			 SPI_MOSI => SPI_MOSI,
			 SPI_CS => SPI_CS,
			 Audio => Audio
        );

   -- Clock process definitions
   Osc_Clk_process :process
   begin
		Osc_Clk <= '0';
		wait for Osc_Clk_period/2;
		Osc_Clk <= '1';
		wait for Osc_Clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
	
	-- Procedure to generate serial data stream from ADC for one sample
	procedure Gen_ADC_data (data : in std_logic_vector(11 downto 0)) is
	begin
		-- Wait for ADC_CS falling edge
		wait until falling_edge(SPI_CS);
		
		-- Set ADC data to zero
		SPI_MISO <= '0';
		
		-- Output 4 consecutive zeros on SPI_MISO
		-- Sync'd to falling edge of SPI_SCLK
		for i in 1 to 4 loop
			exit when SPI_CS = '1';  -- check that CS stays low
			wait until falling_edge(SPI_SCLK);
			exit when SPI_CS = '1';  -- check that CS stays low
			wait until rising_edge(SPI_SCLK);
			exit when SPI_CS = '1';  -- check that CS stays low
		end loop;
		
		-- Output 12 consecutive bits of an ADC sample on SPI_MISO
		-- Sync'd to falling edge of SPI_SCLK
		for i in 11 downto 0 loop
			exit when SPI_CS = '1';  -- check that CS stays low
			wait until falling_edge(SPI_SCLK);
			exit when SPI_CS = '1';  -- check that CS stays low
			wait for 17 ns;  -- tDACC = 17 ns typical, 27 ns max.
			SPI_MISO <= data(i);
			exit when SPI_CS = '1';  -- check that CS stays low
			wait until rising_edge(SPI_SCLK);
			exit when SPI_CS = '1';  -- check that CS stays low
		end loop;
		
		-- set ADC data to zero
		wait until rising_edge(SPI_CS);
		SPI_MISO <= '0';
	end procedure;
	
   begin		
	
      -- insert stimulus here
		
		-- for each test vector, generate the signals and timing for the ADC SPI
		for k in test_data'range loop
			Switch <= test_data(k).Switch;
			Gen_ADC_data(test_data(k).ADC_data);
		end loop;
		
		wait until falling_edge(SPI_CS);
		wait for 1 us;
		wait until falling_edge(SPI_CS);
		Switch(4) <= '1';  -- Use internal DAC test data source
		
      wait;
   end process;

END;
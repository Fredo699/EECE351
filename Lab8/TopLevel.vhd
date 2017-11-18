----------------------------------------------------------------------------------
-- Company Name:   Binghamton University
-- Engineer(s):    Carl Betcher
-- Create Date:    10/25/2016 
-- Module Name:    TopLevel - Behavioral 
-- Project Name:   Lab7
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.DSDtypes_pkg.all; -- use package defined abpve

entity TopLevel is
	 generic (DAC_MSB : integer := 11); -- Sets MSB of DAC input
    Port ( Osc_Clk : in STD_LOGIC;
			  Switch : in  STD_LOGIC_VECTOR (7 downto 4);
           LED : out  STD_LOGIC_VECTOR (7 downto 0);
			  Seg7_SEG : out STD_LOGIC_VECTOR (6 downto 0); 
			  Seg7_DP  : out STD_LOGIC; 
			  Seg7_AN  : out STD_LOGIC_VECTOR (4 downto 0);
			  SPI_SCLK : out STD_LOGIC;
			  SPI_MISO : in STD_LOGIC; 
			  SPI_MOSI : out STD_LOGIC; 
			  SPI_CS : out STD_LOGIC;
			  GPIO : out STD_LOGIC;
			  Audio_left, Audio_right : out STD_LOGIC
			  );
end TopLevel;

architecture Behavioral of TopLevel is

	COMPONENT DivideByN
	Generic ( N : positive := 1600 );
	PORT(
		clk_in : IN std_logic;  
		clk_out : OUT std_logic
		);
	END COMPONENT;

	COMPONENT ADC_Interface
	PORT(
		clk : IN std_logic;
		ADC_number : IN std_logic_vector(2 downto 0);
		Sample : IN std_logic;
		SPI_CS : OUT std_logic;
		SPI_SCLK : out STD_LOGIC;
		SPI_MOSI : OUT std_logic;
		SPI_MISO : IN std_logic;
		ADC_data_out : OUT std_logic_vector(11 downto 0)
		);
	END COMPONENT;

	-- Declare HEXon7segDisp component
	COMPONENT HEXon7segDisp
	PORT(
		hex_data_in0 : IN std_logic_vector(3 downto 0);
		hex_data_in1 : IN std_logic_vector(3 downto 0);
		hex_data_in2 : IN std_logic_vector(3 downto 0);
		hex_data_in3 : IN std_logic_vector(3 downto 0);
		dp_in : IN std_logic_vector(2 downto 0);
		clk : IN std_logic;          
		seg_out : OUT std_logic_vector(6 downto 0);
		an_out : OUT std_logic_vector(3 downto 0);
		dp_out : OUT std_logic
		);
	END COMPONENT;
	
	-- Declare FIR Filter component
	component FIR_Filter is
		Generic (Coeff : FIR_Coeff_type);
		Port ( clk : in STD_LOGIC;
				 Sample : in STD_LOGIC;
				 X : in STD_LOGIC_VECTOR (11 downto 0);
				 Y : out STD_LOGIC_VECTOR (11 downto 0));
	end component;
	
	constant FIR_Coeff : FIR_Coeff_type := (x"537", x"593", x"537");

-- -- DCM Component for Spartan 3E (Papilio One)
--	COMPONENT dcm1
--	PORT(
--		CLKIN_IN : IN std_logic;
--		RST_IN : IN std_logic;          
--		CLKFX_OUT : OUT std_logic;
--		CLK0_OUT : OUT std_logic;
--		LOCKED_OUT : OUT std_logic
--		);
--	END COMPONENT;

	-- DCM Component for Spartan 6 (Papilio Duo)
	COMPONENT dcm1
	PORT
	 (-- Clock in ports
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  CLK_OUT1          : out    std_logic;
	  CLK_OUT2          : out    std_logic;
	  -- Status and control signals
	  RESET             : in     std_logic;
	  LOCKED            : out    std_logic
	 );
	END COMPONENT;

	COMPONENT DeltaSigma_DAC
	GENERIC(MSB : integer := 11);
	PORT(
		clk : IN std_logic;
		DAC_reset : IN std_logic;
		DAC_input : IN std_logic_vector(MSB downto 0);          
		DAC_output : OUT std_logic
		);
	END COMPONENT;

	COMPONENT DAC_Test_Source
	GENERIC(MSB : integer := 11);
	PORT(
		clk : IN std_logic;
		Sample : IN std_logic;          
		DAC_test_data : OUT std_logic_vector(MSB downto 0)
		);
	END COMPONENT;

	-- Signals for Hex Display
	signal HexDisp : std_logic_vector(15 downto 0) := x"0000";
	
	-- Signals for ADC Interface
	signal Sample 	: std_logic; 	  -- sets sample rate of ADC
	signal ADC_data_out : std_logic_vector(11 downto 0);
	
	-- buffered master input clock to DCM1 and SRL16
	signal Clk_BUFG : std_logic;     
	
	-- Signals for DCM
	signal reset_DCM, DAC_clk, Osc_Clk_Buf : std_logic;
	signal DCM1_locked, DCM1_locked_not : std_logic := '0';
	
	-- signal for DAC test data source
	signal DAC_test_data : std_logic_vector(DAC_MSB downto 0);
	
	-- signal for DAC input data
	signal DAC_data_in1 : std_logic_vector(DAC_MSB downto 0);
	signal DAC_data_in2 : std_logic_vector(DAC_MSB downto 0);
	signal FIR_out : std_logic_vector(DAC_MSB downto 0);

begin
	process(Switch(5), Switch(4), ADC_data_out, FIR_out, DAC_test_data) begin
		case Switch(5 downto 4) is
			when "00" =>
				DAC_data_in1 <= x"000";
			when "01" =>
				DAC_data_in1 <= ADC_data_out;
			when "10" =>
				DAC_data_in1 <= FIR_out;
			when others =>
				DAC_data_in1 <= DAC_test_data;
		end case;
	end process;
	
	process(Switch(7), Switch(6), ADC_data_out, FIR_out, DAC_test_data) begin
		case Switch(7 downto 6) is
			when "00" =>
				DAC_data_in2 <= x"000";
			when "01" =>
				DAC_data_in2 <= ADC_data_out;
			when "10" =>
				DAC_data_in2 <= FIR_out;
			when others =>
				DAC_data_in2 <= DAC_test_data;
		end case;
	end process;

	-- Clock divider to reduce 16 MHz to 0.5 MHz to set ADC sample rate
	DivideByN_1: DivideByN PORT MAP(
		clk_in => Osc_Clk_Buf,
		clk_out => Sample 
	);
	
	GPIO <= Sample;

	-- ADC Interface
	ADC_Interface1: ADC_Interface PORT MAP(
		clk => Osc_Clk_Buf,
		ADC_number => "000",
		Sample => Sample,
		SPI_SCLK => SPI_SCLK,
		SPI_CS => SPI_CS,
		SPI_MOSI => SPI_MOSI,
		SPI_MISO => SPI_MISO,
		ADC_data_out => ADC_data_out
	);

	-- Display ADC Output on 7-Segment Disply
	HexDisp <= "0000" & ADC_data_out;

	-- Instantiate Hex to 7-segment conversion module
	HEXon7segDisp1: HEXon7segDisp PORT MAP(
		hex_data_in0 => HexDisp(15 downto 12),
		hex_data_in1 => HexDisp(11 downto 8),
		hex_data_in2 => HexDisp(7 downto 4),
		hex_data_in3 => HexDisp(3 downto 0),
		dp_in => "000",  -- no decimal point
		seg_out => Seg7_SEG,
		an_out => Seg7_AN(3 downto 0),
		dp_out => Seg7_DP,
		clk => Osc_Clk_Buf
	);
		
	Seg7_AN(4) <= '1';
		
   -- BUFG: Global Clock Buffer 
	-- Used to drive clock input of DCM and SRL16
   BUFG_1 : BUFG
   port map (
      O => Clk_BUFG,     -- Clock buffer output
      I => Osc_Clk       -- Clock buffer input
   );

	-- DCM to produce DAC_clk
	dcm1_1 : dcm1  -- Use with Spartan 6
	  port map
		(-- Clock in ports
		 CLK_IN1 => Osc_Clk,
		 -- Clock out ports
		 CLK_OUT1 => Osc_Clk_Buf,  -- 32 MHz Clock
		 CLK_OUT2 => DAC_clk,		-- 96 MHz Clock
		 -- Status and control signals
		 RESET  => reset_DCM,
		 LOCKED => DCM1_locked);

--	dcm1_1: dcm1 PORT MAP(    -- Use with Spartan 3E
--		CLKIN_IN => Osc_Clk,   	-- clock input
--		RST_IN => reset_DCM,   		-- reset DCM
--		CLKFX_OUT => DAC_clk, 		-- DCM generated clock
--		CLK0_OUT => open,
--		LOCKED_OUT => DCM1_locked  -- DCM locked and clock output is valid
--	);
-- Osc_Clk_Buf <= Clk_BUFG;  -- Clock buffer drives system clock for all logic circuits

   -- SRL16 used to generate a power on reset for the DCM
   -- SRL16E: 16-bit shift register LUT with clock enable operating on posedge of clock
   --        Spartan-6
   -- Xilinx HDL Language Template, version 14.7
   SRL16E_inst : SRL16E
   generic map (
      INIT => X"000F")
   port map (
      Q   => reset_DCM, 	-- Q   - SRL data output
      A0  => '1',   			-- A0  - Select[0] input
      A1  => '1',   			-- A1  - Select[1] input
      A2  => '1',   			-- A2  - Select[2] input
      A3  => '1',   			-- A3  - Select[3] input
      CE => '1',     		-- Clock enable input
      CLK => Osc_Clk,  		-- CLK - Clock input
      D   => '0'    			-- D   - SRL data input
   );
	
--   -- SRL16: 16-bit shift register LUT operating on posedge of clock
--   --        Spartan-3E
--   -- Xilinx HDL Language Template, version 14.2
--   SRL16_inst : SRL16
--   generic map (
--      INIT => X"000F")
--   port map (
--      Q   => reset_DCM, 		-- Q   - SRL data output
--      A0  => '1',   			-- A0  - Select[0] input
--      A1  => '1',   			-- A1  - Select[1] input
--      A2  => '1',   			-- A2  - Select[2] input
--      A3  => '1',   			-- A3  - Select[3] input
--      CLK => Osc_Clk,  		-- CLK - Clock input
--      D   => '0'    			-- D   - SRL data input
--   );
	
	
	-- D/A Converter
	DCM1_locked_not <= not DCM1_locked;  -- invert DCM1 locked signal
	
	DeltaSigma_DAC1: DeltaSigma_DAC 
	GENERIC MAP(MSB => DAC_MSB)
	PORT MAP(
		clk => DAC_clk,
		DAC_reset => DCM1_locked_not,
		DAC_input => DAC_data_in1,
		DAC_output => Audio_right
	);
	
	DeltaSigma_DAC2: DeltaSigma_DAC 
	GENERIC MAP(MSB => DAC_MSB)
	PORT MAP(
		clk => DAC_clk,
		DAC_reset => DCM1_locked_not,
		DAC_input => DAC_data_in2,
		DAC_output => Audio_left
	);
	
	Fir3tap: FIR_Filter
	GENERIC MAP(Coeff => FIR_Coeff)
	PORT MAP(
		clk => osc_clk_buf,
		Sample=>Sample,
		X=>ADC_DATA_OUT,
		Y=>FIR_out
	);

	-- Test source for DAC - generates ramp function
	DAC_Test_Source1: DAC_Test_Source 
	GENERIC MAP(MSB => DAC_MSB)
	PORT MAP(
		clk => Osc_Clk_Buf,
		Sample => Sample,
		DAC_test_data => DAC_test_data
	);

	-- Misc connections
	LED(7 downto 1) <= "0000000";	
	LED(0) <= DCM1_locked;     -- LED(0) lights when DCM1 is locked
		
end Behavioral;

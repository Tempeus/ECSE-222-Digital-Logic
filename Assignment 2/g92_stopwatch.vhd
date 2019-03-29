library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity g92_stopwatch is
	Port (start		:in std_logic;
			stop		:in std_logic;
			reset		:in std_logic;
			clk		:in std_logic;
			HEX0		:out std_logic_vector (6 downto 0 );
			HEX1		:out std_logic_vector (6 downto 0 );
			HEX2		:out std_logic_vector (6 downto 0 );
			HEX3		:out std_logic_vector (6 downto 0 );
			HEX4		:out std_logic_vector (6 downto 0 );
			HEX5		:out std_logic_vector (6 downto 0 )
			);
end g92_stopwatch;

architecture behaviour of g92_stopwatch is 

	-- 7-segment decoder
	component g92_7_segment_decoder is
		port( 
			code 					: in std_logic_vector (3 downto 0);
			segments				: out std_logic_vector (6 downto 0)
		);
	end component g92_7_segment_decoder;
	
	-- counter
	component g92_counter is
		Port (
					enable : in std_logic;
					reset  : in std_logic;
					clk 	 : in std_logic;
					count  : out std_logic_vector(3 downto 0)
					
				);
	end component g92_counter;
	-- clock divider
	
	component g92_clock_divider is
	Port (
				enable : in std_logic;
				reset  : in std_logic;
				clk    : in std_logic;
				en_out : out std_logic
		);
		
	end component g92_clock_divider;
	
	-- store the Binary outputs of counters
	signal HEX0_B			: std_logic_vector (3 downto 0);
	signal HEX1_B			: std_logic_vector (3 downto 0);
	signal HEX2_B			: std_logic_vector (3 downto 0);
	signal HEX3_B			: std_logic_vector (3 downto 0);
	signal HEX4_B			: std_logic_vector (3 downto 0);
	signal HEX5_B			: std_logic_vector (3 downto 0);
	
	-- enable for each time counters
	signal enable_0		: std_logic;
	signal enable_1		: std_logic;
	signal enable_2		: std_logic;
	signal enable_3		: std_logic;
	signal enable_4		: std_logic;
	signal enable_5		: std_logic;
	
	-- reset for each time counters
	signal reset_0			: std_logic;
	signal reset_1			: std_logic;
	signal reset_2			: std_logic;
	signal reset_3			: std_logic;
	signal reset_4			: std_logic;
	signal reset_5			: std_logic;
	
	-- special signal for millisecond counter
	signal millisecond_enable : std_logic;
	
	signal stopwatch_memory_state : std_logic := '0';
	
	signal clock_div_enable : std_logic;
	
	--  the logic
	
	--hex0 and hex1 represent milliseconds and can run from 00-99
	--hex2 and hex3 represent seconds and can run from 00-59
	--hex4,5 represent minutes an drun from 00-59
	
	
begin
	--create clock divider
	Clock_Divider_0: g92_clock_divider PORT MAP (enable => clock_div_enable, reset => reset, clk => clk, en_out => enable_0);
	
	--create 6 counters for each digit
	counter_0: g92_counter PORT MAP(enable => millisecond_enable, reset => reset_0, clk => clk, count => HEX0_B (3 downto 0));
	counter_1: g92_counter PORT MAP(enable => enable_1, reset => reset_1, clk => clk, count =>HEX1_B (3 downto 0));
	counter_2: g92_counter PORT MAP(enable => enable_2, reset => reset_2, clk => clk, count =>HEX2_B (3 downto 0));
	counter_3: g92_counter PORT MAP(enable => enable_3, reset => reset_3, clk => clk, count =>HEX3_B (3 downto 0));
	counter_4: g92_counter PORT MAP(enable => enable_4, reset => reset_4, clk => clk, count =>HEX4_B (3 downto 0));
	counter_5: g92_counter PORT MAP(enable => enable_5, reset => reset_5, clk => clk, count =>HEX5_B (3 downto 0));
	
	-- create 6 decoders for each digit
	
	decoder_0: g92_7_segment_decoder PORT MAP (code => HEX0_B(3 downto 0), segments => HEX0(6 downto 0));
	decoder_1: g92_7_segment_decoder PORT MAP (code => HEX1_B(3 downto 0), segments => HEX1(6 downto 0));
	decoder_2: g92_7_segment_decoder PORT MAP (code => HEX2_B(3 downto 0), segments => HEX2(6 downto 0));
	decoder_3: g92_7_segment_decoder PORT MAP (code => HEX3_B(3 downto 0), segments => HEX3(6 downto 0));
	decoder_4: g92_7_segment_decoder PORT MAP (code => HEX4_B(3 downto 0), segments => HEX4(6 downto 0));
	decoder_5: g92_7_segment_decoder PORT MAP (code => HEX5_B(3 downto 0), segments => HEX5(6 downto 0));
	process(start, stop, reset, clk)
		begin
				
			if (stop = '0') then
				clock_div_enable <= '0';
			elsif falling_edge(start) then
				clock_div_enable <= '1';
			end if;
			
		millisecond_enable <= enable_0;
		stopwatch_memory_state <= clock_div_enable;
		
		-- set enable/not for each digit to increase
		if (HEX0_B = "1001") then
			enable_1 <= millisecond_enable;
		else enable_1 <= '0';
		end if;
		
		if (HEX1_B = "1001") then
			enable_2 <= enable_1;
		else 
			enable_2 <= '0';
		end if;
		
		if (HEX2_B = "1001") then
			enable_3 <= enable_2;
		else 
			enable_3 <= '0';
		end if;
		
		if (HEX3_B = "0101") then
			enable_4 <= enable_3;
		else 
			enable_4 <= '0';
		end if;
		
		
	
		if (HEX4_B = "1001") then
			enable_5 <= enable_4;
		else 
			enable_5 <= '0';
		end if;
		
		
		
-- reset hex0 when it becomes greater than 9
		
		if (HEX0_B = "1010" or reset = '0') then
			reset_0 <= '0';
		else 
			reset_0 <= '1';
		end if;
		
-- reset hex1 when it becomes greater than 9
		
		if (HEX1_B = "1010" or reset = '0') then
			reset_1 <= '0';
		else 
			reset_1 <= '1';
		end if;
		
-- reset hex2 when it becomes greater than 9
		
		if (HEX2_B = "1010" or reset = '0') then
			reset_2 <= '0';
		else 
			reset_2 <= '1';
		end if;
		
-- reset hex3 when it becomes greater than 5
		
		if (HEX3_B = "0110" or reset = '0') then
			reset_3 <= '0';
		else 
			reset_3 <= '1';
		end if;
		
-- reset hex4 when it becomes greater than 9
		
		if (HEX4_B = "1010" or reset = '0') then
			reset_4 <= '0';
		else 
			reset_4 <= '1';
		end if;
	
		if (HEX5_B = "0110" or reset = '0') then
			reset_5 <= '0';
		else 
			reset_5 <= '1';
		end if;
	end process;
	
	

end behaviour;
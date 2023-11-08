library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation_tb is
 generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;

architecture tb of exponentiation_tb is
   
    constant c_CLOCK_PERIOD : time := 300 ns; 
  
	signal a 		    : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal b 		    : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
   	signal n 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal K 			: STD_LOGIC_VECTOR ( 7 downto 0 );

	signal ready_out 	: STD_LOGIC;
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	
	signal clk 			: STD_LOGIC := '0';
	signal reset 		: STD_LOGIC := '0';
	signal enable       : STD_LOGIC := '0';
	
	
begin
	dut: entity work.exponentiation(expBehave) 
	port map 
	(
			a         => a,
			b         => b,
			n         => n,
			K         => K,
			enable    => enable,
			clk       => clk,
			reset     => reset,
		    ready_out => ready_out,
			result    => result
	);
			
    p_CLK_GEN : process is
      begin
        wait for c_CLOCK_PERIOD/2;
        clk <= not clk;
      end process p_CLK_GEN; 
		
    stimulus:
	process begin
	   n <= std_logic_vector(to_unsigned(123129, n'length));
	   K <= std_logic_vector(to_unsigned(11, k'length));
	  
	   wait for 10 ns;

	   enable <= '1';
	   
	   wait for 10 ns;
	          
	   a <= std_logic_vector(to_unsigned(1231, a'length));
	   b <= std_logic_vector(to_unsigned(1221, b'length));
	 
	   wait;
	   
	   --reset <= '1';
	   
	end process stimulus;
	   
end tb;


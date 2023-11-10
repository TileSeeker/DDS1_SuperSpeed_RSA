library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

entity blakely_tb is
 generic (
		C_block_size : integer := 260
	);
end blakely_tb;

architecture tb of blakely_tb is
   
    constant c_CLOCK_PERIOD : time := 300 ns; 
  
	signal a 		    : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal b 		    : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
   	signal n 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal K 			: STD_LOGIC_VECTOR ( 15 downto 0 );

	signal ready_out 	: STD_LOGIC;
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	
	signal clk 			: STD_LOGIC := '0';
	signal reset 		: STD_LOGIC := '0';
	signal enable       : STD_LOGIC := '0';
	
begin
	dut: entity work.blakely(blakelyBehave) 
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
		
    stimulus: process is
              
     begin
	   
	   n <= x"099925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"; --std_logic_vector(to_unsigned(123129, n'length));
	   K <= std_logic_vector(to_unsigned(C_block_size, k'length));
	   
	   a <= x"00a23232323232323232323232323232323232323232323232323232323232323"; --std_logic_vector(to_unsigned(1, a'length));
	   b <= x"00a23232323232323232323232323232323232323232323232323232323232323"; --std_logic_vector(to_unsigned(1, b'length));
	
	   wait for 10 ns;

	   enable <= '1';
	   	          
	   wait until ready_out='1';
	   assert result = x"024931802b9ead447563ec7f0f3d613270a5dd5f3d3df1457b9857de14da1a750" report "Blakley Calc Failed!" severity failure;
	  	   
	   wait for 100 ns;
	   
	   reset <= '1';

	   wait for 100 ns;
	   
	   reset <= '0';
	   
    	   
       assert false report "Test: OK" severity failure;
	end process stimulus;
	   
end tb;


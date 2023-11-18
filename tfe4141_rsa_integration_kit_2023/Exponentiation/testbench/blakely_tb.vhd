library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

entity blakely_tb is
 generic (
		C_block_size : integer := 256
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
	   
	   n <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"; --std_logic_vector(to_unsigned(123129, n'length));
	   K <= std_logic_vector(to_unsigned(C_block_size, k'length));
	   
	   a <= x"0000000011111111222222223333333344444444555555556666666677777777"; --std_logic_vector(to_unsigned(1, a'length));
	   b <= x"0000000011111111222222223333333344444444555555556666666677777777"; --std_logic_vector(to_unsigned(1, b'length));
	
	   wait for 10 ns;

	   enable <= '1';
	   	          
	   wait until ready_out='1';
	  	   
	   wait for 100 ns;
	   
	   assert result <= x"5f3a4171696ab4e8aefbabb6e786a1449fe8187a1130ad91a0220ab6aebc5ba6" report "Failed";
	   
	   wait for 100 ns;

       enable <= '0';
	  
	   reset <= '1';
	   
	   wait for 200 ns;

	   reset <= '0';
	   
	   wait for 200 ns;
	   	   
	   a <= x"0000000000000000000000000000000000000000000000000000000000000001"; --std_logic_vector(to_unsigned(1, a'length));
	   b <= x"0000000000000000000000000000000000000000000000000000000000000001"; 
	  
	   wait for 200 ns;
	   
	   enable <= '1';
	   
	   wait until ready_out ='1';
	   	  
	   wait for 1000 ns; 
	   	   
	   enable <= '0';
	  
	   reset <= '1';
	   
	   wait for 100 ns;
	   
	   assert false report "Test Done" severity Failure;

	end process stimulus;
	   
end tb;


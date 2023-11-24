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
    
    -- Test encryption/decruption of different combinations of a and b, could be expanded with more alternatives
    
     begin
	   
	   n <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"; --std_logic_vector(to_unsigned(123129, n'length));
	   K <= std_logic_vector(to_unsigned(C_block_size, k'length));
	   
	   a <= x"0000000011111111222222223333333344444444555555556666666677777777"; --std_logic_vector(to_unsigned(1, a'length));
	   b <= x"0000000011111111222222223333333344444444555555556666666677777777"; --std_logic_vector(to_unsigned(1, b'length));
	
	   wait for 10 ns;
	   
	   reset <= '1';
	   
	   wait for 10 ns;
	   
	   reset <= '0';
	   
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
	   	   
	   a <= x"8bd9ee778b33d324448f3e7da4599f2995ed107677c219951be78fc6ad6d66e1"; --std_logic_vector(to_unsigned(1, a'length));
	   b <= x"8bd9ee778b33d324448f3e7da4599f2995ed107677c219951be78fc6ad6d66e1"; 
	  
	   wait for 200 ns;
	   
	   enable <= '1';

	   wait until ready_out ='1';
	   
	   assert result <= x"791926f8d56aab7416200646de7eae2a183acc44556def87e8662333e39d07b7" report "Failed";

	   wait for 100 ns; 
	   
	   enable <= '0';
	   reset <= '1';
	   
	   wait for 100 ns;

	   reset <= '0';
	   	   
	   wait for 200 ns;
	   	   
	   a <= x"35af3347ca27e90b60d026503503217878fcc8f5f8cead531883ced661849cbd"; 
	   b <= x"35af3347ca27e90b60d026503503217878fcc8f5f8cead531883ced661849cbd"; 
	  
	   wait for 100 ns;
	   
	   enable <= '1';

	   wait until ready_out ='1';
	   
	   assert result <= x"1e24ffdda862cf7d8c0d3be17d002ec4c55c41ad5509201547b6b93fc4f546bd" report "Failed";
	   
	   wait for 100 ns;

       enable <= '0';
       
       wait for 100 ns;
       	  
	   reset <= '1';
	   
	   wait for 200 ns;

	   reset <= '0';
	   	   
	   wait for 100 ns;
	   	   
	   a <= x"8bd9ee778b33d324448f3e7da4599f2995ed107677c219951be78fc6ad6d66e1"; --std_logic_vector(to_unsigned(1, a'length));
	   b <= x"8bd9ee778b33d324448f3e7da4599f2995ed107677c219951be78fc6ad6d66e1"; 
	  
	   wait for 100 ns;
	   
	   enable <= '1';

	   wait until ready_out ='1';
	   
	   assert result <= x"791926f8d56aab7416200646de7eae2a183acc44556def87e8662333e39d07b7" report "Failed";

	   wait;

	end process stimulus;
	   
end tb;


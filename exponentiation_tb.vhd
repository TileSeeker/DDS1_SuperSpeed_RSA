library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation_tb is
 generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;

architecture tb of exponentiation_tb is
   
    constant c_CLOCK_PERIOD : time := 100 ns; 
  
	signal a 		    : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal b 		    : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal key 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
   	signal n 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal K 			: STD_LOGIC_VECTOR ( 7 downto 0 );
    signal enable       : STD_LOGIC;

	signal ready_out 	: STD_LOGIC;
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	
	signal clk 			: STD_LOGIC;
	signal restart 		: STD_LOGIC;

begin
	dut: entity work.exponentiation(expBehave) port map 
	(
			a         => a,
			b         => b,
			key       => key,
			n         => n,
			K         => K,
			enable    => enable,
			clk       => clk,
			restart   => restart,
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
	   n <= std_logic_vector(to_unsigned(143, n'length));
	   key <= std_logic_vector(to_unsigned(17, key'length));
	   K <= std_logic_vector(to_unsigned(36, k'length));
	   enable <= '1';
	   
	   a <= std_logic_vector(to_unsigned(1, a'length));
	   b <= std_logic_vector(to_unsigned(1, b'length));
	   
	   wait for 0.5 sec;
	   
	   a <= std_logic_vector(to_unsigned(2, a'length));
	   b <= std_logic_vector(to_unsigned(2, b'length));

       wait;
        
	end process stimulus;
	   
end tb;


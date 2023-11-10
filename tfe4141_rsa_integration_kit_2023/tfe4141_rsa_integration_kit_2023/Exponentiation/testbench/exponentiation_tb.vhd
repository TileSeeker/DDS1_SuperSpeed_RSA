library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std .all;


entity exponentiation_tb is
	generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;


architecture expBehave of exponentiation_tb is

	signal message 		: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal key 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal valid_in 	: STD_LOGIC;
	signal ready_in 	: STD_LOGIC;
	signal ready_out 	: STD_LOGIC;
	signal valid_out 	: STD_LOGIC;
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal modulus 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal clk 			: STD_LOGIC := '0';
	signal restart 		: STD_LOGIC;
	signal reset_n 		: STD_LOGIC;
    
    constant freq       : integer := 1e9;
    constant T          : time    := 1sec/freq;  
    
begin
	i_exponentiation : entity work.exponentiation
		port map (
			message   => message  ,
			key       => key      ,
			valid_in  => valid_in ,
			ready_in  => ready_in ,
			ready_out => ready_out,
			valid_out => valid_out,
			result    => result   ,
			modulus   => modulus  ,
			clk       => clk      ,
			reset_n   => reset_n
		);
    
    clk_process: process is
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
    end process;

    DUT: process is
    begin
        message     <= std_logic_vector(to_unsigned(50, message'length));
        key         <= std_logic_vector(to_unsigned(17, key'length));
        modulus     <= std_logic_vector(to_unsigned(143, modulus'length));
        
        valid_in    <= '0';
        
        wait for 1*T;
        reset_n <= '0';
        wait for 1*T;
        reset_n <= '1';
        
        wait until ready_in;
        valid_in <= '1';
        wait until ready_in;
        
        
        wait for 10*T;
        assert false report "Test: OK" severity failure;
    end process;


end expBehave;

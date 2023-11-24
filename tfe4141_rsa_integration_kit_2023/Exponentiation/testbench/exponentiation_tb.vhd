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
	signal valid_in 	: STD_LOGIC := '0';
	signal ready_in 	: STD_LOGIC := '0';
	signal ready_out 	: STD_LOGIC := '0';
	signal valid_out 	: STD_LOGIC;
	signal msgin_last   : STD_LOGIC := '0';
	signal msgout_last  : STD_LOGIC := '0';
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal modulus 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal clk 			: STD_LOGIC := '0';
	signal restart 		: STD_LOGIC := '0';
	signal reset_n 		: STD_LOGIC := '0';
    
    constant freq       : integer := 1e9;
    constant T          : time    := 1sec/freq;  
    begin

	i_exponentiation : entity work.exponentiation
	   generic map(
	       C_block_size=>C_block_size)
		port map (
			message   => message  ,
			key       => key      ,
			valid_in  => valid_in ,
			ready_in  => ready_in ,
			ready_out => ready_out,
			valid_out => valid_out,
			msgin_last => msgin_last,
			msgout_last => msgout_last,
			result    => result   ,
			modulus   => modulus  ,
			clk       => clk      ,
			reset_n   => reset_n
		);
    
    clk_process: process is
    begin
        clk <= '0';     wait for T/2;
        clk <= '1';     wait for T/2;
    end process;

    DUT: process is
    begin
        reset_n <= '0';     wait for T;
        reset_n <= '1';     wait for T;
---------------------------------------------------------
    --Encrypt Test 1
---------------------------------------------------------
        --Encryption
        message     <= std_logic_vector(to_unsigned(50, message'length));
        key         <= std_logic_vector(to_unsigned(17, key'length));
        modulus     <= std_logic_vector(to_unsigned(143, modulus'length));
        valid_in <= '1';    wait for T;
        valid_in <= '0';    wait for T;
        wait until valid_out;
        ready_out <= '1';   wait for T;
        ready_out <= '0';   wait for T;
        assert (result = std_logic_vector(to_unsigned(85, result'length))) report "Test: Modulo Operation Result Error" severity failure;
        
        --Decryption
        message     <= result;
        key         <= std_logic_vector(to_unsigned(113, key'length));
        valid_in <= '1';    wait for T;
        valid_in <= '0';    wait for T;
        wait until valid_out;
        ready_out <= '1';   wait for T;
        ready_out <= '0';   wait for T;
        assert (result = std_logic_vector(to_unsigned(50, result'length))) report "Test: Modulo Operation Result Error" severity failure;
---------------------------------------------------------
    --Encrypt Test 2
---------------------------------------------------------
        reset_n <= '0';     wait for T;
        reset_n <= '1';     wait for T;
        --Encryption
        message     <= std_logic_vector(to_unsigned(50, result'length));
        key         <= x"0000000000000000000000000000000000000000000000000000000000010001";
        modulus     <= x"d7cff677f3d26cfa6d5ca63cf2ddb7d120ae8abaf11e7b833a2338ca07471bd7";
        valid_in <= '1';    wait for T;
        valid_in <= '0';    wait for T;
        wait until valid_out;
        ready_out <= '1';   wait for T;
        ready_out <= '0';   wait for T;   
            
        --Decryption
        message     <= result;
        key         <= x"005f1e74ae149e7fbf361f1fd0bd3aa69e8b66745f2d50a0b1d82caf648d05c9";
        valid_in <= '1';    wait for T;
        valid_in <= '0';    wait for T;
        wait until valid_out;
        ready_out <= '1';   wait for T;
        ready_out <= '0';   wait for T;       
        assert (result = std_logic_vector(to_unsigned(50, result'length))) report "Test: Modulo Operation Result Error" severity failure;

---------------------------------------------------------
    --Encrypt Test 3
---------------------------------------------------------
        --Encryption
        message     <= x"b64ce14712586ff4e5aa50459bc31d1c3cf7e94727067505189bc67be52baad9";
        key         <= x"0000000000000000000000000000000000000000000000000000000000010001";
        modulus     <= x"d7cff677f3d26cfa6d5ca63cf2ddb7d120ae8abaf11e7b833a2338ca07471bd7";
        valid_in <= '1';    wait for T;
        valid_in <= '0';    wait for T;
        wait until valid_out;
        ready_out <= '1';   wait for T;
        ready_out <= '0';   wait for T;          
        
        --Decryption
        message <= result;
        key         <= x"005f1e74ae149e7fbf361f1fd0bd3aa69e8b66745f2d50a0b1d82caf648d05c9";
        valid_in <= '1';    wait for T;
        valid_in <= '0';    wait for T;
        wait until valid_out;
        ready_out <= '1';   wait for T;
        ready_out <= '0';   wait for T;   
                  
        assert (result = x"b64ce14712586ff4e5aa50459bc31d1c3cf7e94727067505189bc67be52baad9") report "Test: Modulo Operation Result Error" severity failure;
         
    ---------------------------------------------------------
        --Encrypt Test 4
    ---------------------------------------------------------
        --Encryption         
        message     <= x"0a232020207478742e6e695f307470203a2020202020202020202020454d414e";
        key         <= x"0000000000000000000000000000000000000000000000000000000000010001";
        modulus     <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
        valid_in <= '1';    wait for T;
        valid_in <= '0';    wait for T;
        wait until valid_out;     
        ready_out <= '1';   wait for T;
        ready_out <= '0';   wait for T; 
        assert (result = x"85EE722363960779206A2B37CC8B64B5FC12A934473FA0204BBAAF714BC90C01") report "Test: Modulo Operation Result Error" severity failure;
             
        assert false report "Test: OK" severity failure;
    end process;


end expBehave;

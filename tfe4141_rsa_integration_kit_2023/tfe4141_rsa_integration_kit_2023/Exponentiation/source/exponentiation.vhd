library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC
	);
end exponentiation;


architecture expBehave of exponentiation is
signal rst: std_logic;

begin
	--result <= message xor modulus;
	--ready_in <= ready_out;
	--valid_out <= valid_in;
	
	rst <= not(reset_n);
	valid_out <= ready_in;
	
	Binary: entity work.binary(rtl)
	port map(
    rst => rst,
    clk => clk,
    en  => valid_in,
    rdy => ready_in,
    
    M  => Message,
    N  => Modulus,
    e  => key,
    C  => result);
	
end expBehave;
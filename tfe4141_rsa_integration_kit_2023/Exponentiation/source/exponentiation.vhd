library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256;
		core_count        : integer range 15 downto 1 := 2
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		msgin_last  : in STD_LOGIC;
		ready_in	: out STD_LOGIC;
		

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

		--ouput controll
		ready_out	: in STD_LOGIC;
		msgout_last : out STD_LOGIC;
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
	rst <= not(reset_n);
	
	Binary: entity work.binary(rtl)
	generic map(
	block_size => C_block_size)
	port map(
    rst => rst,
    clk => clk,
    en  => valid_in,
    rdy => ready_in,
    valid_out => valid_out,
    ready_out => ready_out,
    msgin_last => msgin_last,
    msgout_last => msgout_last,
    
    M  => Message,
    N  => Modulus,
    e  => key,
    C  => result);
end expBehave;

architecture core_gen of exponentiation is
signal rst: std_logic;
signal count_in     : integer range core_count-1 downto 0 := 0;
signal count_out    : integer range core_count-1 downto 0 := 0;

signal valid_in_vector      : std_logic_vector (core_count-1 downto 0) := (others=>'0');
signal ready_in_vector      : std_logic_vector (core_count-1 downto 0) := (others=>'0');
signal valid_out_vector     : std_logic_vector (core_count-1 downto 0) := (others=>'0');
signal ready_out_vector     : std_logic_vector (core_count-1 downto 0) := (others=>'0');
signal msgin_last_vector    : std_logic_vector (core_count-1 downto 0) := (others=>'0');
signal msgout_last_vector   : std_logic_vector (core_count-1 downto 0) := (others=>'0');

begin
    rst <= not(reset_n);
    
    core_generate: for i in 0 to core_count-1 generate
    begin
    
    Binary: entity work.binary(rtl)
	generic map(
	block_size => C_block_size)
	port map(
    rst         => rst,
    clk         => clk,
    en          => valid_in_vector(i),
    rdy         => ready_in_vector(i),
    valid_out   => valid_out_vector(i),
    ready_out   => ready_out_vector(i),
    msgin_last  => msgin_last_vector(i),
    msgout_last => msgout_last_vector(i),
    
    M  => Message,
    N  => Modulus,
    e  => key,
    C  => result);
    end generate;
    
   mux_in_generate: for i in 0 to core_count-1 generate
   begin
    if (count_in = i) then
        valid_in_vector(i)      <= valid_in;
        ready_in_vector(i)      <= ready_in;
        msgin_last_vector(i)    <= msgin_last;
    end if;
   end generate;
   
    



end architecture;
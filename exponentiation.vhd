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
		n         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); 
        K         : in STD_LOGIC_VECTOR(8 downto 0);

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

-- Invoke binary method to provide a and b from message m, or send it dircectly as input

architecture expBehave of exponentiation is
    signal R                    :    std_logic_vector(C_block_size-1 downto 0);
    signal a                    :    std_logic_vector(C_block_size-1 downto 0);
    signal b                    :    std_logic_vector(C_block_size-1 downto 0);
    
begin
     BLAKELY : process(sysclk) is

          variable bit_shift_pos               :    integer                             :=  0;
          variable right_shift                 :    unsigned(8 downto 0)                :=  "0000";
          variable i                           :    unsigned(8 downto 0)                :=  "0000";
          variable a_multiply_en               :    unsigned(8 downto 0)                :=  "0000";
          variable and_test                    :    unsigned(8 downto 0)                :=  "0001";
          
          begin 
               if rising_edge(sysclk) and k /= i then

                    bit_shift_pos   := to_integer(unsigned(unsigned(K)-i-1));
                    right_shift     := shift_right(unsigned(a), bit_shift_pos);
                    
                    and_test := right_shift and and_test;
                    
                    if(and_test = 0) then
                        a_multiply_en := "0000";
                    else 
                        a_multiply_en := "0001";
                    end if;
                      
                    R <= std_logic_vector( unsigned(R) + unsigned(R) + a_multiply_en * unsigned(b));
                    
                    if( unsigned(R) >= unsigned(n)) then
                         R <= std_logic_vector(unsigned(R) - unsigned(n));
                    if( unsigned(R) >= unsigned(n)) then
                         R <= std_logic_vector(unsigned(R)-unsigned(n));

                    i := i + 1;
                    
                end if;
          end process BLAKELY;
          
         result <= R;
         ready_in <= ready_out;
         valid_out <= valid_in;
        
end expBehave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input data
		a             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); 
		b             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); 
		key 		  : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		n             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); 
        K             : in STD_LOGIC_VECTOR (7 downto 0);
        enable        : in STD_LOGIC;
		clk 		  : in STD_LOGIC;
		restart 	  : in STD_LOGIC;
		ready_out	  : out STD_LOGIC;
		result 		  : out STD_LOGIC_VECTOR(C_block_size-1 downto 0)
	);
end exponentiation;

architecture expBehave of exponentiation is
    signal R                    :    std_logic_vector(C_block_size-1 downto 0);
    signal i                    :    unsigned(7 downto 0)  :=  "00000000";

begin
     BLAKELY : process(clk, enable) is

          variable bit_shift_pos               :    integer                                     :=  0;
          variable right_shift                 :    std_logic_vector(C_block_size-1 downto 0)   := (others => '0');
          variable and_operation               :    std_logic_vector(C_block_size-1 downto 0)   := (others => '0');
          variable and_result                  :    std_logic_vector(C_block_size-1 downto 0)   := (others => '0');
          
          begin 
               
               if rising_edge(clk) and enable = '1' then
                    ready_out <= '0';
                    
                    bit_shift_pos   := to_integer(unsigned(unsigned(K)-i-1));
                    right_shift     := std_logic_vector(shift_right(unsigned(a), bit_shift_pos));
                    and_result      := std_logic_vector(unsigned(right_shift) and unsigned(and_operation));
                    
                    if(unsigned(and_result) = 1) then
                        R <= std_logic_vector( unsigned(R) + unsigned(R) + unsigned(b) );
                    else
                        R <= std_logic_vector( unsigned(R) + unsigned(R));
                    end if;
                    
                     if( unsigned(R) >= unsigned(n)) then
                         R <= std_logic_vector(unsigned(R) - unsigned(n));
                    end if;
                    
                    if( unsigned(R) >= unsigned(n)) then
                         R <= std_logic_vector(unsigned(R)-unsigned(n));
                    end if;

                    i <= i + 1;
                    
               end if;
         end process BLAKELY;
          
         result <= R;
         ready_out <= '1' when unsigned(K) = i;
        
end expBehave;

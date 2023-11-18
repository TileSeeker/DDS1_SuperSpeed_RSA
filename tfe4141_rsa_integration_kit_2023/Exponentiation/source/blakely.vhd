library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity blakely is
	generic (
		C_block_size : integer := 256
	);
	port (
		a             : in  STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); 
		b             : in  STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); 
		n             : in  STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); 
        K             : in  STD_LOGIC_VECTOR ( 15 downto 0);
        enable        : in  STD_LOGIC;
		clk 		  : in  STD_LOGIC;
		reset 	      : in  STD_LOGIC;
		
		ready_out	  : out STD_LOGIC;
		result 		  : out STD_LOGIC_VECTOR(C_block_size-1 downto 0)
	);
end blakely;

architecture blakelyBehave of blakely is

    signal i            : unsigned(15 downto 0)  := (others => '0');
    signal blakely_done : STD_LOGIC             := '0';
    
    type State_Type is (idle, encrypt);
    signal current_state, next_state : State_Type;
           
    --constant C_FILE_NAME :string  := "C:\tfe4141_rsa_integration_kit_2023\Exponentiation\output.txt";
    --file fptr: text;
begin

    ------------------------------------------------------------------------------
     STATE_MEMORY : process(all) is --clk, reset
     begin
        current_state <= current_state;
        if(reset = '1') then
            current_state <= idle;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
     end process STATE_MEMORY;
    ------------------------------------------------------------------------------
    
    ------------------------------------------------------------------------------
    NEXT_STATE_LOGIC : process(all)--clk, enable, blakely_done
        begin 
                next_state <= next_state;
                case(current_state) is
                    when encrypt => if(i >= unsigned(K)) then
                                        ready_out <= '1';
                                        next_state <= idle;                               
                                    end if;
                                    
                    when idle =>  if(enable = '1') then
                                    next_state <= encrypt;
                                  end if;
                end case;
   end process NEXT_STATE_LOGIC;
    ------------------------------------------------------------------------------

    ------------------------------------------------------------------------------
    BLAKELY : process(all) is --clk, current_state, i, reset
    
      variable bit_shift_pos         :    integer                                     :=  0;
      variable right_shift           :    std_logic_vector(C_block_size-1 downto 0)   := (others => '0');
      variable and_operation         :    std_logic_vector(C_block_size-1 downto 0)   := std_logic_vector(to_unsigned(1, right_shift'length));
      variable and_result            :    std_logic_vector(C_block_size-1 downto 0)   := (others => '0');
      variable R                     :    std_logic_vector(260   downto 0)   := (others => '0');
      
      --variable fstatus      :file_open_status;
      --variable file_line     :line;

      begin
        R:= R;
            case(current_state) is 
                when encrypt =>
                        if(reset = '1') then
                            R := (others => '0');
                            result <= R(C_block_size-1 downto 0);
                            i <= (others => '0');
                            blakely_done <= '0';
                        elsif(i = unsigned(K)) then
                             result <= R(C_block_size-1 downto 0);
                             blakely_done <= '1';
                             --file_close(fptr);
                        else
                            --file_open(fstatus, fptr, C_FILE_NAME, append_mode);
                            --hwrite(file_line, R, left, 0);
                            --writeline(fptr, file_line);
                        
                            bit_shift_pos   := to_integer(unsigned(unsigned(K)-i-1));
                            right_shift     := std_logic_vector(shift_right(unsigned(a), bit_shift_pos));
                            and_result      := std_logic_vector(unsigned(right_shift) and unsigned(and_operation));
                        
                            if(unsigned(and_result) = 1) then
                                R := std_logic_vector( unsigned(R) + unsigned(R) + ('0' & unsigned(b)) );
                            else
                                R := std_logic_vector( unsigned(R) + unsigned(R));
                            end if;
                            
                            if( unsigned(R) >= unsigned(n)) then
                                 R := std_logic_vector(unsigned(R) -('0' & unsigned(n)));
                            end if;
                           
                            if( unsigned(R) >= unsigned(n)) then
                                 R := std_logic_vector(unsigned(R) -('0' & unsigned(n)));
                            end if;
                            
                            if ( i /= unsigned(K)) then
                               i <= i + 1;   
                            end if;   
                                                          
                       end if;
                    
             when idle =>
                 if(reset = '1') then
                    R := (others => '0');
                    i <= (others => '0');
                    blakely_done <= '0';
                    ready_out <= '0';
                 end if;
           
           end case;
     end process BLAKELY;
     
    ------------------------------------------------------------------------------
    
end architecture blakelyBehave;

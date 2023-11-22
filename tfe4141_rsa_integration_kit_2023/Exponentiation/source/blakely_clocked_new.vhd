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

    signal blakely_done :  STD_LOGIC                    := '0';
    signal blakely_state : std_logic_vector(2 downto 0) := (others => '0');
   
    type State_Type is (idle, encrypt);
    signal current_state, next_state : State_Type;
           
    --constant C_FILE_NAME :string  := "C:\tfe4141_rsa_integration_kit_2023\Exponentiation\output.txt";
    --file fptr: text;
    
begin
    
    ------------------------------------------------------------------------------
     STATE_MEMORY : process(all) is --clk, reset
     begin
         if(rising_edge(clk)) then
             if(reset = '1') then
                    current_state <= idle;
             else
                    current_state <= next_state;
             end if;
         end if;
     end process STATE_MEMORY;
    ------------------------------------------------------------------------------
    
    ------------------------------------------------------------------------------
    NEXT_STATE_LOGIC : process(all) is --enable, current_state, blakely_done
        begin
        if(rising_edge(clk)) then 
            case(current_state) is
                when encrypt => if(blakely_done = '1') then
                                    ready_out <= '1';
                                    next_state <= idle;                               
                                end if;
                                
                                if(blakely_done = '0') then
                                    ready_out <= '0';
                                end if;
                                
                when idle =>  if(enable = '1' and blakely_done = '0') then
                                next_state <= encrypt;
                              end if;
                              
                              if(enable = '0' and blakely_done = '0') then
                                 ready_out <= '0';
                                 next_state <= idle;
                              end if;
                              
                              if(blakely_done = '1') then
                                next_state <= idle;
                              end if;
                                      
               when others =>
                    next_state <= idle;  
                    
           end case;
      end if;
   end process NEXT_STATE_LOGIC;
    ------------------------------------------------------------------------------

    ------------------------------------------------------------------------------
    BLAKELY : process(all) is --clk, reset
    
      variable bit_shift_pos         :    integer                                     :=  0;
      variable right_shift           :    std_logic_vector(C_block_size-1 downto 0)   := (others => '0');
      variable and_operation         :    std_logic_vector(C_block_size-1 downto 0)   := std_logic_vector(to_unsigned(1, right_shift'length));
      variable and_result            :    std_logic_vector(C_block_size-1 downto 0)   := (others => '0');
      variable R                     :    std_logic_vector(C_block_size downto 0)     := (others => '0');
      variable i                     :    unsigned(15 downto 0)  := (others => '0'); 
      
      --variable fstatus      :file_open_status;
      --variable file_line     :line;
        
      begin 
      
       if(reset = '1') then
            R := (others => '0');
            result <= (others => '0');
            i := (others => '0');
            blakely_done <= '0';
            blakely_state <= "000" ;
       end if;
        
      if(rising_edge(clk)) then
            case(current_state) is
                when encrypt =>    
                        if(i = unsigned(K)) then
                             result <= R(C_block_size - 1 downto 0);
                             blakely_done <= '1';
                             R := (others => '0');
                             i := (others => '0');
                             --file_close(fptr);
                        else
                            --file_open(fstatus, fptr, C_FILE_NAME, append_mode);
                            --hwrite(file_line, R, left, 0);
                            --writeline(fptr, file_line);
                                                    
                            if(blakely_state = "000") then
                                bit_shift_pos   := to_integer(unsigned(unsigned(K)-i-1));
                                right_shift     := std_logic_vector(shift_right(unsigned(a), bit_shift_pos));
                                and_result      := std_logic_vector(unsigned(right_shift) and unsigned(and_operation));
                                blakely_state <= "001";
                                
                            elsif (blakely_state = "001") then
                                if(unsigned(and_result) = 1) then
                                    R := std_logic_vector( unsigned(R) + unsigned(R) + unsigned(b) );
                                else
                                    R := std_logic_vector( unsigned(R) + unsigned(R));
                                end if;
                                blakely_state <= "010";

                            elsif (blakely_state = "010") then
                                if( unsigned(R) >= unsigned(n)) then
                                     R := std_logic_vector(unsigned(R) - unsigned(n));
                                end if;
                                blakely_state <= "011";
                              
                           elsif(blakely_state = "011") then
                                if( unsigned(R) >= unsigned(n)) then
                                     R := std_logic_vector(unsigned(R) - unsigned(n));
                                end if;
                                blakely_state <= "100";
                                
                           else
                                if ( i /= unsigned(K)) then
                                   i := i + 1;   
                                end if;  
                                blakely_state <= "000" ;
                           end if;
                                                          
                       end if;
                    
             when idle =>                 
                 if(blakely_done = '0') then
                    result <= (others => '0');
                 end if;
                 
            when others => 
                R := (others => '0');
                i := (others => '0');    
                blakely_state <= "000" ;
           end case;
           
     end if;
           
           
     end process BLAKELY;
     
    ------------------------------------------------------------------------------
    
end architecture blakelyBehave;

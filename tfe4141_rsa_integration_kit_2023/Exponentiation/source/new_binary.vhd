library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary is
	generic (
		block_size : integer := 256
	);
port(
    rst         :   in      std_logic;
    clk         :   in      std_logic;
    en          :   in      std_logic;
    rdy         :   out     std_logic;
    valid_out   :   out     std_logic;
    ready_out   :   in      std_logic;
    msgin_last  :   in      std_logic;
    msgout_last :   out     std_logic;
    
    M           :   in      std_logic_vector(block_size-1 downto 0);
    N           :   in      std_logic_vector(block_size-1 downto 0);
    e           :   in      std_logic_vector(block_size-1 downto 0);
    C           :   out     std_logic_vector(block_size-1 downto 0));
end binary;

architecture rtl of binary is

    type state_type is (rdy_state, init_state, start_state, b1_init_state, b1_start_state, b1_wait_state, b1_reset_state, 
                        b2_init_state, b2_start_state, b2_wait_state, b2_reset_state, rst_state, finished_state);
                  
    signal state, next_state : state_type := rdy_state;
    
    
    signal a_input_select   : std_logic;
    signal c_reg_select     : integer range 2 downto 0;
    --Blakley IO signals
    
    --In
    signal blakley_start    : std_logic;
    signal blakley_reset    : std_logic;
    signal blakley_a        : std_logic_vector (block_size-1 downto 0);
    signal blakley_b        : std_logic_vector (block_size-1 downto 0);
    signal blakley_modulo   : std_logic_vector (block_size-1 downto 0);   
    signal blakley_a_msb    : std_logic_vector (15 downto 0)            := std_logic_vector(to_unsigned(block_size, 16));
    
    --Out
    signal blakley_done     : std_logic;
    signal blakley_out      : std_logic_vector (block_size-1 downto 0);
    
    --Counter IO
    signal counter_rst      : std_logic;
    signal counter_dec      : std_logic;
    signal count            : integer range block_size downto 0;
    
    --e_index
    signal e_index_value    : std_logic;
    signal e_ext            : std_logic_vector(block_size downto 0);    
    
    signal message_buffer       : std_logic_vector (block_size-1 downto 0);
    signal message_buffer_write : std_logic;
    signal blakley_buffer       : std_logic_vector (block_size-1 downto 0);
    signal blakley_buffer_write : std_logic;
    signal msg_last_buffer      : std_logic;
    
begin
Blakley: entity work.blakely(blakelyBehave) 
    generic map(
    C_block_size => block_size)
	port map 
	(
			a         => blakley_a,
			b         => blakley_b,
			n         => blakley_modulo,
			K         => blakley_a_msb,
			enable    => blakley_start,
			clk       => clk,
			reset     => blakley_reset,
		    ready_out => blakley_done,
			result    => blakley_out
	);

counter: process(all) is
variable counter_dec_trigger_v : std_logic_vector(1 downto 0) := (others => '0');
begin
    if counter_rst = '1' then
        count <= block_size;
        counter_dec_trigger_v := "00";
    else
        if rising_edge(clk) then
            counter_dec_trigger_v := counter_dec_trigger_v(0)&counter_dec;
            if (counter_dec_trigger_v = "01") then
                count <= count - 1;
            else
                count <= count;
            end if;
        end if;
    end if;
end process;


Blakley_a_input_select: process(all)
begin
if rising_edge (clk) then
    blakley_b <= blakley_buffer;
    blakley_a <= blakley_buffer;
    if (a_input_select='1') then
        blakley_a <= message_buffer;        
    end if;
end if;
end process;

Reg_C_input_select: process(all)
begin
    if rising_edge(clk) then
    case c_reg_select is
        when 1 =>
            C <= blakley_out;
        when 2 =>
            C <= std_logic_vector(to_unsigned(1, block_size));
        when others =>
            C <= C;
    end case;
    end if;
end process;

blakley_input_buffer: process(all) is
begin 
    if rising_edge(clk) then
        blakley_buffer <= blakley_buffer;
        if (blakley_buffer_write='1') then
            blakley_buffer <= C;   
        end if;
    end if;
end process;

input_message_buffer: process(all) is
begin 
    if rising_edge(clk) then
        message_buffer <= message_buffer;
        msg_last_buffer <= msg_last_buffer;
        if (message_buffer_write='1') then
            message_buffer <= M;
            msg_last_buffer <= msgin_last;   
            
        end if;
    end if;
end process;

--e_index_value assignment
e_ext <= ('0' & e);
e_index_value <= e_ext(count);
blakley_modulo <= N;

/*
en_edge_detect: process(en, clk)
    variable rdy_state_clk_counter: integer range 255 downto 0 := 0;
begin
    --rdy <= '1' when ((state=rdy_state) and (en='1')) else '0';
    if rising_edge(clk) then
        rdy <= '0';
        rdy_state_clk_counter := rdy_state_clk_counter;
        if ((en='1')and (state=rdy_state)) then
            rdy_state_clk_counter := rdy_state_clk_counter + 1;
            if (rdy_state_clk_counter=1) then
                rdy <= '1';
            end if;
        else
            rdy_state_clk_counter := 0;
        end if;
    end if;
end process;
*/



Output_Logic: process(all) is
begin
        rdy                     <= '0';
        counter_rst             <= '0';
        counter_dec             <= '0';
        a_input_select          <= '0';
        blakley_start           <= '0';
        blakley_reset           <= '0';
        c_reg_select            <=  0;
        blakley_buffer_write    <= '0';
        message_buffer_write    <= '0';
        valid_out               <= '0';
        msgout_last             <= '0';
        case state is  
            when rdy_state =>
                message_buffer_write <= '1';
            when init_state =>
                rdy <= en;             
                
            when start_state =>
                counter_rst     <= '1';
                blakley_reset   <= '1';
                c_reg_select    <=  2;
                
           
            when b1_init_state=>      
                blakley_buffer_write <= '1';
                
            when b1_start_state =>
                counter_dec     <= '1';
                blakley_start   <= '1';
            
            when b1_wait_state =>
                c_reg_select    <=  1;
                
            when b1_reset_state =>
                blakley_reset   <= '1';
                
            when b2_init_state =>      
                blakley_buffer_write <= '1';
            
            when b2_start_state =>        
                a_input_select  <= '1';
                blakley_start   <= '1';
            
            when b2_wait_state =>         
                a_input_select  <= '1';
                c_reg_select    <=  1;
                
            when b2_reset_state =>
                blakley_reset   <= '1';
                
            when finished_state =>
                valid_out <='1';    
                msgout_last <= msg_last_buffer;
                --rdy <= ready_out;
                
            when rst_state =>
                blakley_reset   <= '1';
                c_reg_select    <=  2;
        end case;
end process;


Next_State_Logic: process(all) is
begin
    if rst then
        next_state <= rst_state;
    else
        if rising_edge(clk) then
            case state is
            when rdy_state =>
                if (en='1') then
                    next_state <= init_state;
                else
                    next_state <= next_state;
                end if;
            when init_state =>
                next_state <= start_state;       
            
            when start_state =>
                next_state <= b1_init_state;

            when b1_init_state =>
                next_state <= b1_start_state;                
                
            when b1_start_state =>
                next_state <= b1_wait_state;
                
            when b1_wait_state =>
                if (blakley_done='1') then
                    next_state <= b1_reset_state;
                else
                    next_state <= next_state;
                end if;
            
            when b1_reset_state =>
                
                if      ((e_index_value/='1') and (count=0)) then
                    next_state <= finished_state;
                elsif   (e_index_value='1') then
                    next_state <= b2_init_state;
                else 
                    next_state<= b1_init_state;
                end if;
                
            when b2_init_state =>
                next_state <= b2_start_state;     
            
            when b2_start_state =>
                next_state <= b2_wait_state;
            
            when b2_wait_state =>
                if (blakley_done) then
                    next_state <= b2_reset_state;
                else
                    next_state <= next_state;
                end if;
                
            when b2_reset_state =>
                if count=0 then
                    next_state <= finished_state;
                else
                    next_state <= b1_init_state;
                end if;
                
            when finished_state =>
                next_state <= next_state;
                if (valid_out and ready_out) then
                    next_state <= rdy_state;
                end if;
                
            when rst_state =>
                next_state <= rdy_state;    
            end case;   
        end if;
    end if;
    state <= next_state;
end process;
end rtl;
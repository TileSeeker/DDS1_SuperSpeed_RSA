library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary is
port(
    rst :   in std_logic;
    clk :   in std_logic;
    en  :   in std_logic;
    rdy :   out std_logic;
    
    M   :   in std_logic_vector(255 downto 0);
    N   :   in std_logic_vector(255 downto 0);
    e   :   in std_logic_vector(255 downto 0);
    C   :   out std_logic_vector(255 downto 0));
end binary;

architecture rtl of binary is
    --signal run: std_logic := '0';
    
    --signal a1, b1, a2, b2, R1, R2: std_logic_vector(255 downto 0):=(others=>'0');
    --signal rst_edge: std_logic_vector(1 downto 0);
    
    type state_type is (rdy_state, start_state, b1_init_state, b1_start_state, b1_wait_state, b1_reset_state, b2_init_state, b2_start_state, b2_wait_state, b2_reset_state, rst_state);
    signal state, next_state : state_type := rdy_state;
    
    
    signal a_input_select   : std_logic;
    signal c_reg_select     : integer range 2 downto 0;
    --Blakley IO signals
    
    --In
    signal blakley_start    : std_logic;
    signal blakley_reset    : std_logic;
    signal blakley_a        : std_logic_vector (C'length-1 downto 0);
    signal blakley_b        : std_logic_vector (C'length-1 downto 0);
    signal blakley_modulo   : std_logic_vector (N'length-1 downto 0);   
    signal blakley_a_msb    : std_logic_vector (7 downto 0)            := std_logic_vector(to_unsigned(255, 8));
    
    --Out
    signal blakley_done     : std_logic;
    signal blakley_out      : std_logic_vector (C'length-1 downto 0);
    
    --Counter IO
    signal counter_rst      : std_logic;
    signal counter_dec      : std_logic;
    signal count            : integer range 256 downto 0;
    
    --e_index
    signal e_index_value    : std_logic;
    signal e_ext            : std_logic_vector(256 downto 0);    
    
    signal blakley_buffer     : std_logic_vector (C'length-1 downto 0);
    signal blakley_buffer_write: std_logic;
    
begin
Blakley: entity work.blakely(blakelyBehave) 
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


counter: process(counter_rst, clk) is
variable counter_dec_trigger_v : std_logic_vector(1 downto 0) := (others => '0');
begin
    if counter_rst = '1' then
        count <= 256;
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


Blakley_a_input_select: process(clk)
begin
if rising_edge (clk) then
    blakley_b <= blakley_buffer;
    blakley_a <= blakley_buffer;
    if (a_input_select='1') then
        blakley_a <= M;        
    end if;
end if;
end process;

Reg_C_input_select: process(clk)
begin
    if rising_edge(clk) then
    case c_reg_select is
        when 1 =>
            C <= blakley_out;
        when 2 =>
            C <= std_logic_vector(to_unsigned(1, C'length));
        when others =>
            C <= C;
    end case;
    end if;
end process;


blakley_input_buffer: process(clk) is
begin 
    if rising_edge(clk) then
        blakley_buffer <= blakley_buffer;
        if (blakley_buffer_write='1') then
            blakley_buffer <= C;   
        end if;
    end if;
end process;

--e_index_value assignment
e_ext <= ('0' & e);
e_index_value <= e_ext(count);
blakley_modulo <= N;

Output_Logic: process(state) is
begin
    rdy                     <= '0';
    counter_rst             <= '0';
    counter_dec             <= '0';
    a_input_select          <= '0';
    blakley_start           <= '0';
    blakley_reset           <= '0';
    c_reg_select            <=  0;
    blakley_buffer_write    <= '0';
    case state is  
        when rdy_state =>
            rdy <= '1';
       
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
            
        when rst_state =>
            blakley_reset   <= '1';
            c_reg_select    <=  2;
            blakley_buffer_write <= '0';
    end case;
end process;


Next_State_Logic: process(rst, clk) is
begin
    if rst then
        next_state <= rst_state;
    else
        if rising_edge(clk) then
            case state is
            when rdy_state =>
                if (en='1') then
                    next_state <= start_state;
                else
                    next_state <= next_state;
                end if;
    
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
                if(e_index_value) then
                    next_state <= b2_init_state;
                else
                    next_state <= b1_init_state;
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
                    next_state <= rdy_state;
                else
                    next_state <= b1_init_state;
                end if;
                
            when rst_state =>
                next_state <= rdy_state;    
            end case;   
        end if;
    end if;
    state <= next_state;
end process;
end rtl;
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
    
    type state_type is (rdy_state, start_state, b1_start_state, b1_wait_state, b2_start_state, b2_wait_state, rst_state);
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
			reset     => rst,
		    ready_out => blakley_done,
			result    => blakley_out
	);


counter: process(all) is
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

Blakley_a_input_select: process(all)
begin
    blakley_b <= C;
    if (a_input_select='1') then
        blakley_a <= M;
    else
        blakley_a <= C;
    end if;
end process;

Reg_C_input_select: process(all)
begin
    case c_reg_select is
        when 0 => 
            C <= C;
        when 1 =>
            C <= blakley_out;
        when 2 =>
            C <= std_logic_vector(to_unsigned(1, C'length));
    end case;

end process;


--e_index_value assignment
e_ext <= ('0' & e);
e_index_value <= e_ext(count);
blakley_modulo <= N;

Output_Logic: process(all) is
begin
    case state is
        when rdy_state =>
            rdy <= '1';
            counter_rst     <= '0';
            counter_dec     <= '0';
            a_input_select  <= '0';
            blakley_start   <= '0';
            blakley_reset   <= '0';
            c_reg_select    <=  0;
            
        when start_state =>
            rdy             <= '0';
            counter_rst     <= '1';
            counter_dec     <= '0';
            a_input_select  <= '0';
            blakley_start   <= '0';
            blakley_reset   <= '0';
            c_reg_select    <=  2;
             
        
        when b1_start_state =>
            rdy             <= '0';
            counter_rst     <= '0';
            counter_dec     <= '1';
            a_input_select  <= '0';
            blakley_start   <= '1';
            c_reg_select    <=  1;
        
        when b1_wait_state =>
            rdy             <= '0';
            counter_rst     <= '0';
            counter_dec     <= '0';
            a_input_select  <= '0';
            blakley_start   <= '0';
            c_reg_select    <= 0;
        
        when b2_start_state =>
            rdy             <= '0';
            counter_rst     <= '0';
            counter_dec     <= '0';            
            a_input_select  <= '1';
            blakley_start   <= '1';
            c_reg_select    <=  1;
        
        when b2_wait_state =>
            rdy             <= '0';
            counter_rst     <= '0';
            counter_dec     <= '0';            
            a_input_select  <= '1';
            blakley_start   <= '0';
            c_reg_select    <=  0;
            
            
        when rst_state =>
            rdy             <= '0';
            counter_rst     <= '0';
            counter_dec     <= '0';            
            a_input_select  <= '0';
            blakley_start   <= '0';
            c_reg_select    <=  2;
            
    end case;
end process;


Next_State_Logic: process(all) is
begin
    if rising_edge(clk) then
        case state is
        when rdy_state =>
            if (en='1') then
                next_state <= start_state;
            else
                next_state <= next_state;
            end if;

        when start_state =>
            next_state <= b1_start_state;
            
            
        when b1_start_state =>
            next_state <= b1_wait_state;
            
        when b1_wait_state =>
            if (blakley_done='1') then
                if(e_index_value) then
                    next_state <= b2_start_state;
                else
                    next_state <= b1_start_state;
                end if;
            else
                next_state <= next_state;
            end if;
        
        when b2_start_state =>
            next_state <= b2_wait_state;
        
        when b2_wait_state =>
            if (blakley_done) then
                if count=0 then
                    next_state <= rdy_state;
                else
                    next_state <= b1_start_state;
                end if;
            else
                next_state <= next_state;
            end if;
            
        when rst_state =>
            next_state <= rdy_state;    
        end case;
        state <= next_state;
    end if;
end process;
end rtl;

/*
    rst_edge <= rst_edge(0) & rst;

    Blakley_1: entity work.blakley(rtl)
    port map(
    a => a1,
    b => b1,
    N => n,
    R => R1);
    
    Blakley_2: entity work.blakley(rtl)
    port map(
    a  => a2,
    b  => b2,
    N  => n,
    R  => R2);

main: process(all)
    variable C_v: std_logic_vector(255 downto 0):= std_logic_vector (to_unsigned(1,C'length));
    variable count_v: integer range 255 downto 0 := 255; 
    variable run_v: std_logic := '0';
    variable rdy_v: std_logic := '0';
    
begin
    --Reset Program
    if (rst='1') then
        C_v :=(others => '0');
        run_v := '0';
        rdy_v := '0';
        
    else 
        C_v := C_v;
        run_v := run_v;
        if (rst_edge = "10") then --falling edge detect
            rdy_v := '1';
        else
            rdy_v := rdy_v;
        end if;
    end if;
    
    --Start Program
    if (en='1' and run='0' and rdy='1') then
        run_v := '1';
        rdy_v := '0';
        
        if e(C'length-1) = '1' then
            C_v := M;    
        else
            C_v := std_logic_vector (to_unsigned(1,C'length));    
        end if;
        
        count_v := C'length-2;
    else
        run_v := run_v;
        rdy_v := rdy_v;
        count_v := count_v;
    end if;    
    
   --Algorithm
   if rising_edge(clk) then
        if  (run='1') then
            if (count_v = 0) then
                run_v := '0';
                rdy_v := '1';
            else 
                C_v := std_logic_vector((unsigned(C) * unsigned(C)) mod unsigned(n));
                if e(count-1) = '1' then
                    C_v := std_logic_vector((unsigned(C_v) * unsigned(M)) mod unsigned(n));
                else 
                    C_v := C_v;
                end if;   
                count_v := count_v - 1;
            end if;
        else
            C_v := C_v;
            count_v := count_v;
            rdy_v := rdy_v;
        end if;
   end if;
   run <= run_v;
   count <= count_v;  
   C <= C_v;
   rdy <= rdy_v;
end process main;

*/
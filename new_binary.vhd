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
--signal i: integer range (e'length-1) to 0;
--signal C_reg: std_logic_vector(255 downto 0);
    signal run: std_logic := '0';
    
    signal a1, b1, a2, b2, R1, R2: std_logic_vector(255 downto 0):=(others=>'0');
    signal rst_edge: std_logic_vector(1 downto 0);
    
    type state_type is (rdy_state, start_state, b1_start_state, b1_wait_state, b2_start_state, b2_wait_state, rst_state);
    signal state, next_state : state_type := rdy_state;
    
    --Blakley IO signals
    --In
    signal blakley_start    : std_logic;
    signal blakley_a        : std_logic_vector (C'length downto 0);
    signal blakley_b        : std_logic_vector (C'length downto 0);
    signal blakley_modulo   : std_logic_vector (N'length downto 0);   
    signal blakley_a_msb    : std_logic_vector (7 downto 0)            := std_logic_vector(to_unsigned(255, 7));
    
    --Out
    signal blakley_done     : std_logic;
    signal blakley_out      : std_logic_vector (C'length downto 0);
    
    --Counter IO
    signal counter_rst      : std_logic;
    signal counter_dec      : std_logic;
    signal counter_empty    : std_logic;
    signal count            : integer range 256 downto 0;
    
    --e_index
    signal e_index_value    : std_logic;    
    
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

/*
counter: process is
begin
if counter_rst = '1' then
    counter_out = 0;
else
    if rising_edge(clk) then
        if 
    
    end if;
end if

end process;
*/

--e_index_value assignment
e_index_value <= e(count);



FSM: process(all) is
begin
if rising_edge(clk) then
    case state is
    when rdy_state =>
        rdy <= '1';
        
        if (en='1') then
            next_state <= start_state;
        else
            next_state <= next_state;
        end if;
    
    when start_state =>
        rdy <= '0';
        
        --count <= e'length; Count Reset
        C <= std_logic_vector(to_unsigned(1, C'length));
        blakley_modulo <= N;
    
    when b1_start_state =>
        rdy <= '0';
        
        blakley_a <= C;
        blakley_b <= C;
        blakley_start <= '1';

        next_state <= b1_wait_state;
        
    when b1_wait_state =>
        rdy <= '0';
        if (blakley_done) then
            if(e_index_value) then
                next_state <= b2_start_state;
            else
                next_state <= b1_start_state;
        else
            next_state <= next_state;
        end if;
    
    when b2_start_state =>
        rdy <= '0';

        blakley_a <= M;
        blakley_b <= C;

        next_state <= b1_wait_state;
    
    when b2_wait_state =>
        rdy <= '0';
        if (blakley_done) then
            if count=0 then
                next_state <= b1_start_state;
            else
                next_state <= rdy_state;
            end if;
        else
            next_state <= next_state;
        end if;
        
    when rst_state =>
        rdy <= '0';    
        
    end case;
    
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
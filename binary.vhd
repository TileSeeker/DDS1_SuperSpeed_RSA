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
    signal count: integer range 256 downto 0 := 255;
    signal run: std_logic := '0';
    
    signal a1, b1, a2, b2, R1, R2: std_logic_vector(255 downto 0):=(others=>'0');
    signal rst_edge: std_logic_vector(1 downto 0);
begin
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

end rtl;
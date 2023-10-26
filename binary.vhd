library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary is
port(
    rst:    in std_logic;
    clk :   in std_logic;
    e_msb_pos: in integer range 0 to 255 := 255;
    M:      in std_logic_vector(255 downto 0);
    N:      in std_logic_vector(255 downto 0);
    e:      in std_logic_vector(255 downto 0);
    C :     out std_logic_vector(255 downto 0));
end binary;

architecture rtl of binary is
--signal i: integer range (e'length-1) to 0;
--signal C_reg: std_logic_vector(255 downto 0);

begin

binary: process(all)
    --variable e_shift: std_logic_vector(e'length downto 0) := e;
    --variable i_max: integer range 0 to 2*e'length := 2*e'length;
    variable C_var: std_logic_vector(255 downto 0):= std_logic_vector (to_unsigned(1,C'length));
begin
    if rising_edge(rst) then
        C <=(others => '0');
    else
        for i in (e'length-1) downto 0 loop
            --report "i=" & integer'image(i);
            if i = (e'length-1) then
                --Set C to 1
                C <= std_logic_vector(to_unsigned(1, C'length));  
            end if;
            
            C_var := std_logic_vector((unsigned(C_var) * unsigned(C_var)));-- mod unsigned(e));
            if e(i)='1' then
                C_var := std_logic_vector((unsigned(C_var) * unsigned(M)));-- mod unsigned(e));
            else
                C_var := C_var;
            end if;              
        end loop;
        C <= C_var;
    end if;
    
end process binary;

end rtl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blakley_tb is
end entity;

architecture tb of blakley_tb is
    signal a, b ,n, R: std_logic_vector(255 downto 0) := (others=>'0');
    constant freq: integer := 1e9;
    constant T: time := 1sec/freq;
begin
    DUT: entity work.blakley(rtl)
    port map(
    a => a,
    b => b,
    n => n,
    R => R);
    
    test: process
    begin
        a <= std_logic_vector(to_unsigned(3, a'length));
        b <= std_logic_vector(to_unsigned(7, a'length));
        n <= std_logic_vector(to_unsigned(13, a'length));
        
        wait for 10*T;
        assert (R= std_logic_vector(to_unsigned(8, R'length))) report "Test: Modulo Operation Result Error" severity failure;
    end process;

end tb;
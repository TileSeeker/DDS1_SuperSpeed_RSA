library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_tb is
end entity;

architecture tb of binary_tb is
    signal rst  :   std_logic := '0';
    signal clk  :   std_logic := '0';
    signal en   :   std_logic := '0';
    signal rdy  :   std_logic := '0';
    
    signal M    :   std_logic_vector(255 downto 0) := (others=>'0');
    signal N    :   std_logic_vector(255 downto 0) := (others=>'0');
    signal e    :   std_logic_vector(255 downto 0) := (others=>'0');
    signal C    :   std_logic_vector(255 downto 0) := (others=>'0');
    
    --constant freq: integer := 1e10;
    --constant T: time := 1sec/freq;
    constant T: time := 100ps;
begin
DUT: entity work.binary(rtl)
    port map(
    rst => rst,
    clk =>clk,
    en => en,
    rdy => rdy,
    M => M,
    N => N,
    e => e,
    C => C);
    
   clk <= not(clk) after T/2;
   
   test: process is
   begin
   rst <= '0';
   wait for 5 ns;
   rst <= '1';
   en <= '0';
   wait for 5 ns;
   rst <= '0';
   wait for 5 ns;
   
   M <= std_logic_vector(to_unsigned(50, M'length));
   e <= std_logic_vector(to_unsigned(17, e'length));
   n <= std_logic_vector(to_unsigned(143, n'length));
   wait for 5ns;
   en <= '1';
    wait for 5ns;
   
   
   --wait for 2000*T;
   wait until rdy='1';
   assert (C = std_logic_vector(to_unsigned(85, C'length))) report "Test: Modulo Operation Result Error" severity failure;
   
   assert false report "Test: OK" severity failure;
   end process test;
  
   
end tb;


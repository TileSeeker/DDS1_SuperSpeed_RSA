library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_tb is
end entity;

architecture tb of binary_tb is
    signal rst:    std_logic := '0';
    signal clk:    std_logic := '0';
    signal e_msb_pos: integer range 0 to 255 := 255;
    signal M:      std_logic_vector(255 downto 0) := (others=>'0');
    signal N:      std_logic_vector(255 downto 0) := (others=>'0');
    signal e:      std_logic_vector(255 downto 0) := (others=>'0');
    signal C:      std_logic_vector(255 downto 0) := (others=>'0');
    
    --constant freq: integer := 100e3;
    --constant T: integer := 1/freq;
begin
DUT: entity work.binary(rtl)
    port map(
    rst => rst,
    clk =>clk,
    M => M,
    N => N,
    e => e,
    C => C);
    
   clk <= not(clk) after 1 ns;
   rst <= '1', '0' after 5ns;
    
    
   test: process is
   begin
   wait until (rst = '0');
   M <= std_logic_vector(to_unsigned(50, M'length));
   e <= std_logic_vector(to_unsigned(17, e'length));
   wait for 100 ns;   
   assert false report "Test: OK" severity failure;
   end process test;
  
   
end tb;


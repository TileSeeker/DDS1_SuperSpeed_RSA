library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity binary_tb is
	generic (
		block_size : integer := 256
	);
end entity;

architecture tb of binary_tb is
    signal rst          :   std_logic := '0';
    signal clk          :   std_logic := '0';
    signal en           :   std_logic := '0';
    signal rdy          :   std_logic := '0';
    signal valid_out    :   std_logic;
    signal ready_out    :   std_logic := '0';
    
    signal M    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    signal N    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    signal e    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    signal C    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    
    constant T: time := 1ns;
begin

DUT: entity work.binary(rtl)
    generic map (
    block_size => block_size)
    port map(
    rst => rst,
    clk =>clk,
    en => en,
    rdy => rdy,
    ready_out=> ready_out,
    valid_out=> valid_out,
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
   
   M <= std_logic_vector(to_unsigned(50, block_size));
   e <= std_logic_vector(to_unsigned(17, block_size));
   n <= std_logic_vector(to_unsigned(143, block_size));
   wait for 5ns;
   en <= '1';
    wait for 5ns;

   wait until valid_out='1';
   assert (C = std_logic_vector(to_unsigned(85, block_size))) report "Test: Modulo Operation Result Error" severity failure;
   ready_out <= '1';    wait for T;
   ready_out <= '0';    wait for T;
   
   
   rst <= '0';
   wait for 5 ns;
   rst <= '1';
   en <= '0';
   wait for 5 ns;
   rst <= '0';
   wait for 5 ns;
   
   m <= x"b64ce14712586ff4e5aa50459bc31d1c3cf7e94727067505189bc67be52baad9";
   e <= x"0000000000000000000000000000000000000000000000000000000000010001";
   n <= x"d7cff677f3d26cfa6d5ca63cf2ddb7d120ae8abaf11e7b833a2338ca07471bd7";
   wait for T;
   en <= '1';    wait for T;
   
   wait until valid_out='1';
   assert (C = x"d69a72752977ffdd38e5fdb4524183c3aa8c1fbb3791fcd14dd5c8551d6afcd8") report "Test: Modulo Operation Result Error" severity failure;
   M <= C;
   e <= x"005f1e74ae149e7fbf361f1fd0bd3aa69e8b66745f2d50a0b1d82caf648d05c9";
   ready_out <= '1';    wait for T;
   ready_out <= '0';    wait for T;
   
   
   rst <= '0';
   wait for 5 ns;
   rst <= '1';
   en <= '0';
   wait for 5 ns;
   rst <= '0';
   wait for 5 ns;
   en <= '1';
   wait for 5ns;
       

   wait until valid_out='1';
   --assert (C = std_logic_vector(to_unsigned(50, block_size))) report "Test: Modulo Operation Result Error" severity failure;
   assert (C = x"b64ce14712586ff4e5aa50459bc31d1c3cf7e94727067505189bc67be52baad9") report "Test: Modulo Operation Result Error" severity failure;
   assert false report "Test: OK" severity failure;
   end process test;
  
   
end tb;


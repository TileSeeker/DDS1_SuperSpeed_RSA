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
    signal valid_out    :   std_logic := '0';
    signal ready_out    :   std_logic := '0';
    signal msgin_last   :   std_logic := '0';
    signal msgout_last  :   std_logic := '0';
    
    signal M    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    signal N    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    signal e    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    signal C    :   std_logic_vector(block_size-1 downto 0) := (others=>'0');
    
    constant T: time := 1ns;
begin
---------------------------------------------------------
    --Component
---------------------------------------------------------
DUT: entity work.binary(rtl)
    generic map (
    block_size => block_size)
    port map(
    rst => rst,
    clk =>clk,
    en => en,
    rdy => rdy,
    ready_out => ready_out,
    valid_out => valid_out,
    msgin_last => msgin_last,
    msgout_last => msgout_last,
    M => M,
    N => N,
    e => e,
    C => C);
  
---------------------------------------------------------
    --CLK
---------------------------------------------------------  
   clk <= not(clk) after T/2;
   
   
---------------------------------------------------------
    --Test
---------------------------------------------------------
   test: process is
   begin
---------------------------------------------------------
    --Reset
---------------------------------------------------------
   rst <= '1'; wait for T;
   rst <= '0'; wait for T;

---------------------------------------------------------
    --Encrypt Test 1
---------------------------------------------------------
   M <= std_logic_vector(to_unsigned(50, block_size));
   e <= std_logic_vector(to_unsigned(17, block_size));
   n <= std_logic_vector(to_unsigned(143, block_size));
   
   en <= '1'; wait for T;
   en <= '0'; wait for T;
   wait until valid_out;
   ready_out <= '1'; wait for T;
   ready_out <= '0'; wait for T;
   assert (C = std_logic_vector(to_unsigned(85, block_size))) report "Test: Modulo Operation Result Error" severity failure;
   
---------------------------------------------------------
    --Encrypt Test 2
---------------------------------------------------------
    --Encrypt
   m <= x"0000000011111111222222223333333344444444555555556666666677777777";
   e <= x"0000000000000000000000000000000000000000000000000000000000010001";
   n <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
   
   en <= '1'; wait for T;
   en <= '0'; wait for T;
   wait until valid_out;
   ready_out <= '1'; wait for T;
   ready_out <= '0'; wait for T;   
   --Decrypt
   M <= C;
   e <= x"0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9";

   en <= '1'; wait for T;
   en <= '0'; wait for T;
   wait until valid_out;
   ready_out <= '1'; wait for T;
   ready_out <= '0'; wait for T; 
   assert (C = x"0000000011111111222222223333333344444444555555556666666677777777") report "Test: Modulo Operation Result Error" severity failure;
   
   assert false report "Test: OK" severity failure;
   end process test;
  
   
end tb;


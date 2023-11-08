----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.11.2023 13:35:34
-- Design Name: 
-- Module Name: MSB_finder_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MSB_finder_tb is
 generic (
		C_block_size : integer := 256
	 ); 
	
end MSB_finder_tb;

architecture Behavioral of MSB_finder_tb is
    
    signal input : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal msb   : unsigned(7 downto 0);
    
    begin
    
        dut : entity work.MSB_finder(rtl) 
        port map 
        (
                Input     => input,
                MSB       => msb
        );
                
        stimulus : process begin
               input <= std_logic_vector(to_unsigned(134, input'length));
               



               wait for 100 ns;
               
               input <= std_logic_vector(to_unsigned(131232134, input'length));

               wait for 100 ns;
               
               wait;
                
        end process stimulus;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.11.2023 13:09:06
-- Design Name: 
-- Module Name: MSB_finder - Behavioral
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

entity MSB_finder is
     generic (
		C_block_size : integer := 256
	 ); 
	
     Port ( 
         Input : in STD_LOGIC_VECTOR(C_block_size-1 downto 0);
         MSB   : out unsigned(7 downto 0)
     );
end MSB_finder;

architecture rtl of MSB_finder is

    signal index : unsigned(7 downto 0) := to_unsigned(255, 8);
    
    begin
        TEST : process(Input) is
            begin
                -- Check for the most significant bit (leftmost '1')
                for index in 255 downto 0 loop
                    if Input(index) = '1' then
                        MSB <= to_unsigned(index, 8);
                        exit;
                    else
                        MSB <= to_unsigned(0, 8);
                    end if;
                end loop;          
     end process;
end architecture rtl;

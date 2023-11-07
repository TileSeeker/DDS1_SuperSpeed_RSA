library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blakley is
port(
a: in std_logic_vector(255 downto 0);
b: in std_logic_vector(255 downto 0);
n: in std_logic_vector(255 downto 0);
R: out std_logic_vector(255 downto 0));
end blakley;

architecture rtl of blakley is

signal count: integer range 255 downto 0 := 255;
--signal R_a: std_logic_vector(255 downto 0);
--signal R_b: std_logic_vector(255 downto 0);
--signal R_c: std_logic_vector(255 downto 0);
--signal R_d: std_logic_vector(255 downto 0);
--signal R_e: std_logic_vector(255 downto 0);
--signal R_f: std_logic_vector(255 downto 0);
--signal R_g: std_logic_vector(255 downto 0);
--signal index: integer range 0 to 2 := 0;*/
    type R_temp_array is array  (a'high downto 0) of std_logic_vector(255 downto 0);
    signal R_temp : R_temp_array;

begin
    R_temp(a'high) <= (others=>'0');

    blakley_generate: for i in a'high downto 0 generate
    signal R_a: std_logic_vector(255 downto 0);
    signal R_b: std_logic_vector(255 downto 0);
    signal R_c: std_logic_vector(255 downto 0);
    signal R_d: std_logic_vector(255 downto 0);
    signal R_e: std_logic_vector(255 downto 0);
    signal R_f: std_logic_vector(255 downto 0);
    signal R_g: std_logic_vector(255 downto 0);
    signal index: integer range 0 to 2 := 0;
    begin
        BLAKLEY_FIRST: 
        if i = a'high generate
            R_a <= (others=>'0');
        else generate    
            R_a <= R_temp(i);
        end generate BLAKLEY_FIRST;        

        R_b <= std_logic_vector(unsigned(R_a) sll 1);
        R_c <= std_logic_vector(unsigned(R_b) + unsigned(b));
        R_d <= R_c when a(i) = '1' else R_b;
        
        R_e <= std_logic_vector(unsigned(R_d) - unsigned(n));
        R_f <= std_logic_vector(unsigned(R_d) - (2 * unsigned(n)));
        
        index  <=   2 when (unsigned(R_d) >=  2 * unsigned(n)) else
                    1 when (unsigned(R_d) >=  unsigned(n)) else
                    0;
            
        with index select
            R_g <=   R_f when 2,
                     R_e when 1,
                     R_d when others;
        BLAKLEY_LAST:
        if i = 0 generate    
            R <= R_g;
        else generate
            R_temp(i-1) <= R_g;
        end generate;
                        
    end generate blakley_generate;
end rtl;
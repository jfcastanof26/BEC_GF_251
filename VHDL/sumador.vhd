--Suma GF(2^251) 
--
--Autor: Javier Castaño 2015
-----------------------------------------
-------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity sumador is
    Port ( a,b : in  STD_LOGIC_VECTOR (250 downto 0);
           c : out  STD_LOGIC_VECTOR (250 downto 0));
end sumador;

architecture Behavioral of sumador is

begin

c <= a xor b;

end Behavioral;


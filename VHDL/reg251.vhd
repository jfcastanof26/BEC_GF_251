--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg251 is
    Port ( R : in  STD_LOGIC_VECTOR (250 downto 0);
           Q : out  STD_LOGIC_VECTOR (250 downto 0);
           En,clk : in  STD_LOGIC);
end reg251;

architecture Behavioral of reg251 is

begin

process(clk)
	begin
		if rising_edge(clk) then
			if En = '1' then
				Q<=R;
			end if;
		end if;
	end process;

end Behavioral;


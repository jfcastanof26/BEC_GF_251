library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity squaring_module is
    Port ( z : in  std_logic_vector (250 downto 0);
           z_2 : out  std_logic_vector (250 downto 0));
end squaring_module;

architecture Behavioral of squaring_module is
	constant a: integer := 125;
	signal s: std_logic_vector(250 downto 13);
	signal c_s: std_logic_vector(12 downto 0);
	
begin

	vector_s: for i in 125 downto 7 generate 
				s(2*i) <= z(i) xor z(i+122);
				s((2*i) - 1) <= z(i+a) xor z(i+(a-1)) xor z(i+(a-2));
				end generate;
				
	c_vs: for i in 6 downto 4 generate 
				c_s(2*i) <= z(i+244) xor z(i+122) xor z(i);
				c_s((2*i) - 1) <= z(i+a) xor z(i+(a-1)) xor z(i+(a-2));
				end generate;
				
				c_s(6) <= z(250) xor z(3);
				c_s(5) <= z(250) xor z(249) xor z(248) xor z(128) xor z(127) xor z(126);
				c_s(4) <= z(249) xor z(2);
				c_s(3) <= z(249) xor z(248) xor z(127) xor z(126); 
				c_s(2) <= z(249) xor z(1); 
				c_s(1) <= z(248) xor z(126); 
				c_s(0) <= z(250) xor z(249) xor z(0); 
				

	z_2 <= s & c_s;		

end Behavioral;


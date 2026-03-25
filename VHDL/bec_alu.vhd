--ALU GF(2^251) 
--Suma, elevación al cuadrado, multiplicación, inverso multiplicativo

--Autor: Javier Castaño 2015
-----------------------------------------
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_components.all;

entity bec_alu is
    Port (clk, reset: in std_logic;
			 sel: in std_logic_vector(2 downto 0);
			  a,b : in  STD_LOGIC_VECTOR (250 downto 0);
           c : out  STD_LOGIC_VECTOR (250 downto 0);
           ini_mul, ini_inv : in  STD_LOGIC;
           done_mul, done_inv : out  STD_LOGIC);
end bec_alu;

architecture Behavioral of bec_alu is


signal a_m1,sum_s, mul_s, inv_s, sqr_s: std_logic_vector(250 downto 0);

begin

sumadorgen: sumador port map(a,b,sum_s);
mult_gen: multiplier_module port map(clk,reset,ini_mul,a,b,mul_s,done_mul);
inv_gen: itmia port map(clk,reset,ini_inv,done_inv,a,inv_s);
sqr_gen: squaring_module port map(a,sqr_s);

a_m1(250 downto 1) <= a(250 downto 1);
a_m1(0) <= a(0) xor '1';


mux_alu_gen: 
	with sel select
		c<= sum_s when "000",--suma
			 sqr_s when "001",--sqr
			 mul_s when "010",--mul
			 inv_s when "011",---inversor
			 a_m1 when "100",--suma 1
			 a when others; --load: 101

end Behavioral;


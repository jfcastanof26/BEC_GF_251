--------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_components.all;

entity bec_alu_2 is
    Port (clk, reset: in std_logic;
			 sel: in std_logic_vector(1 downto 0);
			  a,b : in  STD_LOGIC_VECTOR (250 downto 0);
           c : out  STD_LOGIC_VECTOR (250 downto 0);
           ini_mul : in  STD_LOGIC;
           done_mul : out  STD_LOGIC);
end bec_alu_2;

architecture Behavioral of bec_alu_2 is


signal sum_s,mul_s,sqr_s: std_logic_vector(250 downto 0);

begin

sumadorgen: sumador port map(a,b,sum_s);
mult_gen: multiplier_module port map(clk,reset,ini_mul,a,b,mul_s,done_mul);
sqr_gen: squaring_module port map(a,sqr_s);

mux_alu_gen: 
	with sel select
		c<= sum_s when "00",--suma
			 sqr_s when "01",--sqr
			 mul_s when "10",--mul
			 a when others; --load: 11

end Behavioral;

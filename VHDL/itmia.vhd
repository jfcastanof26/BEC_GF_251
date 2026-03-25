---------------------------------------------------------------------------------------------------------+
----------------------------------------    INVERSE    --------------------------------------------------�
---------------------------------------------------------------------------------------------------------+
--Cálculo de inverso multiplicativo en GF(2^251) 
--
--Autor: Javier Castaño 2015
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity itmia is
    Port ( clk,reset,start : in  std_logic;
           ready : out  std_logic;
           z : in  std_logic_vector (250 downto 0);
           inv_z : out  std_logic_vector (250 downto 0));
end itmia;

architecture Behavioral of itmia is

component multiplier_module is

port(	clk,reset, start : in std_logic;
		operand1_port : in std_logic_vector(250 downto 0);
		operand2_port : in std_logic_vector(250 downto 0);
		result_port : out std_logic_vector(250 downto 0);
		ready : out std_logic);	

end component;

component squaring_module is
    Port ( z : in  std_logic_vector (250 downto 0);
           z_2 : out  std_logic_vector (250 downto 0));
end component;

signal z_s, mult1, mult2, product, a, a_square, temp, temp_product :  std_logic_vector(250 downto 0);

signal load_z, product_done, start_mult, end_inv : std_logic;
subtype iteration is natural range 0 to 22;
signal current_iteration : iteration;
signal counter: integer range 0 to 125;
signal count_it : integer range 0 to 50 := 0;
signal n : integer range 0 to 14;
begin
process(clk)
begin
	if load_z = '1' then
		z_s <= z;
		temp <= z;
	elsif product_done = '1' then
		temp <= product;
		temp_product <=  product;
	elsif current_iteration = 6 then 
		temp <= a_square;
		if count_it = 0 then n<=2; else count_it <= count_it+1; end if;
		if count_it = 6 then n<=6; else count_it <= count_it+1; end if;
		if count_it = 20 then n<=14; else count_it <= count_it+1; end if;
	elsif  current_iteration = 11 or current_iteration = 14 or current_iteration = 19 or current_iteration = 22 then
		temp <= a_square; count_it <= 0;
	else temp <= temp;
	end if;
end process;
	
square: squaring_module port map (a, a_square);
multiplier1 : multiplier_module port map (clk, reset, start_mult, mult1, mult2, product, product_done);

with end_inv select inv_z <= temp when '1', (others =>'0') when others; 
process(clk, reset, current_iteration)
begin	
case current_iteration is
when 0 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= (others =>'0'); ready <= '1'; end_inv <= '1';
when 1 => start_mult <= '0'; load_z <= '1'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --It #1
when 2 => start_mult <= '1'; load_z <= '0'; mult1 <= z_s;  mult2 <= a_square; a <= temp; ready <= '0'; end_inv <= '0';					    --It #1
when 3 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= (others =>'0'); ready <= '0'; end_inv <= '0'; --Fin It #1 inicio It #2(primera elevacion de It #2)
when 4 => start_mult <= '1'; load_z <= '0'; mult1 <= z_s;  mult2 <= a_square; a <= temp; ready <= '0'; end_inv <= '0';						 --It #2
when 5 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0';   --Fin It #2 inicio It #3(primera elevacion de It #3)
when 6 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --It #3 (2 square)
when 7 => start_mult <= '1'; load_z <= '0'; mult1 <= temp;  mult2 <= temp_product; a <= temp; ready <= '0'; end_inv <= '0'; --It #3
when 8 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --Fin It #3 inicio It #4(elevacion de �ltima It #3)
when 9 => start_mult <= '1'; load_z <= '0'; mult1 <= z_s;  mult2 <= a_square; a <= temp; ready <= '0'; end_inv <= '0'; --It #4
when 10 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0';  --Fin It #4 inicio It #5(primera elevacion de It #5)

when 11 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --It #9 (30 square)
when 12 => start_mult <= '1'; load_z <= '0'; mult1 <= temp;  mult2 <= temp_product; a <= temp; ready <= '0'; end_inv <= '0'; --It #9
when 13 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0';  --Fin It #9 inicio It #10(primera elevacion de It #10)
when 14 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --It #10 (61 square)
when 15 => start_mult <= '1'; load_z <= '0'; mult1 <= temp;  mult2 <= temp_product; a <= temp; ready <= '0'; end_inv <= '0'; --It #10
when 16 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0';  --Fin It #10 inicio It #11(elevacion de �ltima It #10)
when 17 => start_mult <= '1'; load_z <= '0'; mult1 <= z_s;  mult2 <= a_square; a <= temp; ready <= '0'; end_inv <= '0'; --It #11
when 18 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --Fin It #11 inicio It #12(primera elevacion de It #12)
when 19 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --It #12 (124 square)
when 20 => start_mult <= '1'; load_z <= '0'; mult1 <= temp;  mult2 <= temp_product; a <= temp; ready <= '0'; end_inv <= '0'; --It #12
when 21 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0';--Fin It #12 inicio It #13(elevacion de �ltima It #12)
when 22 => start_mult <= '0'; load_z <= '0'; mult1 <= (others =>'0');  mult2 <= (others =>'0'); a <= temp; ready <= '0'; end_inv <= '0'; --Fin calculo inverso
end case;

if reset = '1' then current_iteration <= 0; counter <= 0;

elsif clk'event and clk = '1' then
case current_iteration is
when 0 => if start = '0' then current_iteration <= 1; end if;
when 1 => if start = '1' then current_iteration <= 2; end if; --It #1
when 2 => current_iteration <= 3; --It #1
when 3 => if product_done = '1' then current_iteration <= 4; else current_iteration <= 3; end if; --Fin It #1 e Inicio It #2
when 4 => current_iteration <= 5; --It #2
when 5 => if product_done = '1' then current_iteration <= 6; else current_iteration <= 5; end if; --Fin It #2 e Inicio It #3
when 6 => if counter < n then current_iteration <= 6; counter <= counter+1; else current_iteration <= 7; counter <= 0; end if; --It #3 ----INICIO SECUANCIA DE TRES
when 7 => current_iteration <= 8; --It #3
when 8 => if product_done = '1' then current_iteration <= 9; else current_iteration <= 8; end if; --Fin It #3 e Inicio It #4
when 9 => current_iteration <= 10; --It #4
when 10 => if product_done = '1' then
					if count_it = 50 then current_iteration <= 11; else current_iteration <= 6;end if; --Fin It #4 e Inicio It #5 ----FIN SECUENCIA DE TRES
			  else current_iteration <= 10; end if;
when 11 => if counter < 30 then current_iteration <= 11; counter <= counter+1; else current_iteration <= 12; counter <= 0; end if; --It #9
when 12 => current_iteration <= 13; --It #9
when 13 => if product_done = '1' then current_iteration <= 14; else current_iteration <= 13; end if; --Fin It #9 e Inicio It #10
when 14 => if counter < 61 then current_iteration <= 14; counter <= counter+1; else current_iteration <= 15; counter <= 0; end if; --It #10
when 15 => current_iteration <= 16; --It #10
when 16 => if product_done = '1' then current_iteration <= 17; else current_iteration <= 16; end if; --Fin It #10 e Inicio It #11
when 17 => current_iteration <= 18; --It #11
when 18 => if product_done = '1' then current_iteration <= 19; else current_iteration <= 18; end if; --Fin It #11 e Inicio It #12
when 19 => if counter < 124 then current_iteration <= 19; counter <= counter+1; else current_iteration <= 20; counter <= 0; end if; --It #12
when 20 => current_iteration <= 21; --It #12
when 21 => if product_done = '1' then current_iteration <= 22; else current_iteration <= 21; end if; --Fin It #12 e Inicio It #13
when 22 => current_iteration <= 0; --Fin It #13
end case;
end if;

end process;

end Behavioral;



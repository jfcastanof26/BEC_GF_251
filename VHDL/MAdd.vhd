
-----------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_components.all;

entity MAdd is
    Port ( clk, reset : in  STD_LOGIC;
           din,x1in,y1in,x2in,y2in : in  STD_LOGIC_VECTOR (250 downto 0);
           x3out,y3out : out  STD_LOGIC_VECTOR (250 downto 0);
			  init : in  STD_LOGIC;
           done : out  STD_LOGIC);
end MAdd;

architecture Behavioral of MAdd is

type state_values is (inicio,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,
s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36,s37,s38,s39,s40,s41,s42,
s43,s44,s45,s46,s47,s48,s49,s50,s51,s52,s53,s54,s55,s56,s57,s58,s59,s60,s61,s62,s63,s64,s65,s66,
s67,s68,s69,s70,s71,s72,s73,s74,s75,s76,s77,s78,s79,s80,s81,s82,s83,s84,s85,s86,
s87,s88,s89,s90,s91,s92,s93,s94,s95,s96,s97,s98,s99,s72_1,s61_1,s61_2);	
				
signal actual, futuro: state_values;

signal wea: std_logic_vector(0 downto 0);
signal addra: std_logic_vector(2 downto 0);
signal dina,acum_out,douta: std_logic_vector(250 downto 0);
signal sel_s: std_logic_vector(2 downto 0);
signal sel_a_alu, sel_b_alu: std_logic_vector(2 downto 0);
signal a,b,c: std_logic_vector(250 downto 0);
signal ini_mul_s, ini_inv_s, done_mul_s, done_inv_s: std_logic;
signal sel_a,En_acum, En_x3, En_y3: std_logic;

---constantes para posiciones de memoria ("variables")
constant T1: std_logic_vector(2 downto 0) := "000";
constant T2: std_logic_vector(2 downto 0) := "001";
constant T3: std_logic_vector(2 downto 0) := "010";
constant T4: std_logic_vector(2 downto 0) := "011";
constant T5: std_logic_vector(2 downto 0) := "100";
constant T6: std_logic_vector(2 downto 0) := "101";
constant T7: std_logic_vector(2 downto 0) := "110";
constant T8: std_logic_vector(2 downto 0) := "111";
---Constantes para operaciones de la ALU
constant suma: std_logic_vector(2 downto 0) := "000";
constant sqr: std_logic_vector(2 downto 0) := "001";
constant mul: std_logic_vector(2 downto 0) := "010";
constant inverso: std_logic_vector(2 downto 0) := "011";
constant inc: std_logic_vector(2 downto 0) := "100";
constant load: std_logic_vector(2 downto 0) := "101";

---Constantes para bus de datos de entrada RAM
constant ram_acum: std_logic:= '0';
constant ram_alu: std_logic:= '1';

--Contantes para bus de entrada ALU
constant salida_ram: std_logic_vector(2 downto 0):= "000";
constant salida_acum: std_logic_vector(2 downto 0):= "001";
constant x1: std_logic_vector(2 downto 0):= "010";
constant y1: std_logic_vector(2 downto 0):= "011";
constant x2: std_logic_vector(2 downto 0):= "100";
constant y2: std_logic_vector(2 downto 0):= "101";
constant d: std_logic_vector(2 downto 0):= "110";
-------
begin

ram251sp_gen : ram251sp
  PORT MAP (
    clka => clk,
    wea => wea,
    addra => addra,
    dina => dina,
    douta => douta
	 );
	 
alu_gen: bec_alu port map(clk,reset,sel_s,a,b,c,ini_mul_s,ini_inv_s,done_mul_s,done_inv_s);
acumulador_gen: reg251 port map(c,acum_out,En_acum,clk);
reg_x3_gen: reg251 port map(c,x3out,En_x3,clk);
reg_y3_gen: reg251 port map(c,y3out,En_y3,clk);

------Bus de datos entrada RAM
with sel_a select
		dina<= acum_out when '0',--Acumulador		 
			 c when others; --salida alu
			 
--------------------Bus de datos entrada ALU
with sel_a_alu select
		a<= douta when "000",--salida RAM	 
			 acum_out when "001",--Salida Acumulador
			 x1in when "010",--entrada x1
			 y1in when "011",--entrada y1
			 x2in when "100",--entrada x2
			 y2in when "101",--entrada y2
			 din when others;--entada d
			 			 
with sel_b_alu select
		b<= douta when "000",--salida RAM	 
			 acum_out when "001",--Salida Acumulador
			 x1in when "010",--entrada x1
			 y1in when "011",--entrada y1
			 x2in when "100",--entrada x2
			 y2in when "101",--entrada y2
			 din when others;--entada d
			 
------------------------------------FSM suma de puntos coordenadas afines
fsm_add: process(actual,init,done_mul_s,done_inv_s)		  

		begin

			case actual is

			when inicio =>				
				
				done<= '0'; sel_a<=ram_acum;sel_s<=load;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if init= '1' then					
					futuro <= s0;
				else
					futuro <= inicio;
				end if;
			
			when s0 =>	--Acum = x2 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=d;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x2;sel_b_alu<=y2;
				
				futuro <= s1;		
			
			when s1 =>	--Acum = x2 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x2;sel_b_alu<=y2;
				
				futuro <= s2;	
			
			when s2 =>	--T1 = x2 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x2;sel_b_alu<=y2;
				
				futuro <= s3;
			
			when s3 =>	--Acum = x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=y2;
				
				futuro <= s4;
			
			when s4 =>	--Acum = x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s5;
			
			when s5 =>	--Acum = x1 + x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s6;
			
			when s6 =>	--Acum = x1 + x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s7;
			
			when s7 =>	--T2=x1 + x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s8;
			
			when s8 =>	--Acum = Acum * T1
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s9;
			
			when s9 =>	--Acum = Acum * T1
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s10;
			
			when s10 =>	--Acum = Acum * T1
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s11;
				else
					futuro <= s10;
				end if;
			
			when s11 =>	--Acum = Acum + d
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s12;
			
			when s12 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s13;
			
			when s13 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s14;
			
			when s14 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='1';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s15;
			
			when s15 =>	--Acum = Acum^-1 
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				if done_inv_s = '1' then
					En_acum<='1';
					futuro <= s16;
				else
					futuro <= s15;
				end if;
			
			when s16 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s17;
			
			when s17=>	--T3= inverso denominador
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s18;
			
			when s18=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=y1;
				
				futuro <= s19;
			
			when s19=>	--Acum = x1 + y1
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=y1;
				
				futuro <= s20;
			
			when s20=>	--Acum = (x1 + y1) (x2+y2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s21;
			
			when s21 =>	--Acum = (x1 + y1) (x2+y2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s22;
			
			when s22 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s23;
				else
					futuro <= s22;
				end if;
			
			when s23 =>	--T4 = (x1 +y1) (x2+y2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s24;
			
			when s24 =>	--T4 = (x1 + y1) (x2+y2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s25;
			
			when s25 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s26;
			
			when s26 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s27;
			
			when s27 =>	--T5= x1 + x2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s28;
			
			when s28 =>	--T5 = X1 + X2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s29;
			
			when s29 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s30;
			
			when s30 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s31;
			
			when s31 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s32;
			
			when s32 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s33;
				else
					futuro <= s32;
				end if;
			
			when s33 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s34;
			
			when s34 =>	--T6=parte 1 numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s35;
			
			when s35 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s36;
			
			when s36 =>	--Acum = y1 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s37;
			
			when s37 =>	--Acum = y1 + y2 + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s38;
			
			when s38 =>	--Acum = y1 + y2 + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s39;
			
			when s39 =>	--Acum = x2(y1 + y2 + 1)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s40;
			
			when s40 =>	--Acum = x2(y1 + y2 + 1)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s41;
				
			when s41 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s42;
				else
					futuro <= s41;
				end if;
			
			when s42 =>	--Almacena en T7
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s43;
			
			when s43 =>	--Almacena en T7
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s44;
			
			when s44 =>	--y1y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s45;
			
			when s45 =>	--y1y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s46;
			
			when s46 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s47;
				else
					futuro <= s46;
				end if;
			
			when s47 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s48;
			
			when s48 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s49;
			
			when s49 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s50;
			
			when s50 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s51;
			
			when s51 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s52;
				else
					futuro <= s51;
				end if;
			
			when s52 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s53;
			
			when s53 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s54;
			
			when s54 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s55;
			
			when s55 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s56;
			
			when s56 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_x3<='1';
					futuro <= s57;
				else
					futuro <= s56;
				end if;
			
			when s57 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y1;
				
				futuro <= s58;
			-------------------------------------finaliza cálculo de x3

			when s58 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y1;
				
				futuro <= s59;
			
			when s59 =>	--y1 + y1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=salida_acum;
				
				futuro <= s60;
				
			when s60 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=salida_acum;
				
				futuro <= s61;
			
			when s61 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s61_1;
			
			when s61_1 =>	--Almacena en T2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s61_2;
			
			when s61_2 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s62;
				
			when s62 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s63;
			
			when s63 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s64;
				else
					futuro <= s63;
				end if;
			
			when s64 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s65;
			
			when s65 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s66;
			
			when s66 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s67;
			
			when s67 =>	--calcula inverso denominador
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='1';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s68;
			
			when s68 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				if done_inv_s = '1' then
					En_acum<='1';
					futuro <= s69;
				else
					futuro <= s68;
				end if;
			
			when s69 =>	--almacena T3
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s70;
			
			when s70 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s71;
			
			when s71 =>	--y1 + y2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s72;
			
			when s72 =>	--y1 + y2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s72_1;
			
			when s72_1 =>	--y1 + y2 + T4
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s73;
			
			when s73 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s74;
			
			when s74 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s75;
			
			when s75 =>	--d(primera parte numerador)
				
				done<= '0';sel_a<=ram_alu;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s76;
			
			when s76 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s77;
				else
					futuro <= s76;
				end if;
			
			when s77 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s78;
				
			when s78 =>	--Almacena en T6
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s79;
				
			when s79 =>	--x1 + x2 + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=d;
				
				futuro <= s80;
			
			when s80 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=d;
				
				futuro <= s81;
			
			when s81 =>	--y2(x1+x2+1)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s82;
			
			when s82 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s83;
			
			when s83 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s84;
				else
					futuro <= s83;
				end if;
			
			when s84 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s85;
			
			when s85 =>	--Almacena en T7
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='1';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s86;
			
			when s86 =>	--x1x2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s87;
			
			when s87 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s88;
			
			when s88 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s89;
				else
					futuro <= s88;
				end if;
			
			when s89 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s90;
			
			when s90 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s91;
			
			when s91 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s92;
			
			when s92 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s93;
			
			
			when s93 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s94;
				else
					futuro <= s93;
				end if;
			
			when s94 =>	--suma numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s95;
			
			when s95 =>	--suma numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x3<='0';En_y3<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s96;
			
			when s96 =>	--num/den
			
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s97;
			
			when s97 =>	--num/den
			
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s98;
			
			when s98 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_y3<='1';--Almacena y3
					futuro <= s99;
				else
					futuro <= s98;
				end if;
				
			when s99 =>	--fin de Madd
			
				done<= '1';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x3<='0';En_y3<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s98;
				
			end case;			

end process fsm_add;

sincronismo : process(clk,futuro,reset)
	
begin
    	if(reset = '1') then		
      	actual <= inicio;				
      elsif rising_edge(clk) then						
			actual <= futuro;				
      end if;
end process sincronismo;

end Behavioral;


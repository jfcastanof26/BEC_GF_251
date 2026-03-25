--Artimética curva de Edwards sobre GF(2^251) 
--Suma, doblado

--Autor: Javier Castaño 2015
-----------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_components.all;

entity AritBEC is
    Port ( clk, reset : in  STD_LOGIC;
           din,x1in,y1in,x2in,y2in : in  STD_LOGIC_VECTOR (250 downto 0);
           xout_add,yout_add,xout_doub,yout_doub : out  STD_LOGIC_VECTOR (250 downto 0);
			  init, sel_op,sel_doub : in  STD_LOGIC;
           done : out  STD_LOGIC);
end AritBEC;

architecture Behavioral of AritBEC is

type state_values is (inicio,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,
s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36,s37,s38,s39,s40,s41,s42,
s43,s44,s45,s46,s47,s48,s49,s50,s51,s52,s53,s54,s55,s56,s57,s58,s59,s60,s61,s62,s63,s64,s65,s66,
s67,s68,s69,s70,s71,s72,s73,s74,s75,s76,s77,s78,s79,s80,s81,s82,s83,s84,s85,s86,
s87,s88,s89,s90,s91,s92,s93,s94,s95,s96,s97,s98,s99,s72_1,s61_1,s61_2,
s100,s101,s102,s103,s104,s105,s106,s107,s108,s109,s110,s111,s112,s113,s114,s115,s116,s117,
s118,s119,s120,s121,s122,s123,s124,s125,s126,s127,s128,s129,s130,s131,s132,s133,s134,s135,s136,
s137,s138,s139,s140,s141,s142,s143,s144,s145,s146,s147,s148,s149,s150,s151,s152,s153,s154,
s155,s156,s157,s158,s159);	
				
signal actual, futuro: state_values;

signal we: std_logic;
signal addra: std_logic_vector(2 downto 0);
signal addra_s: std_logic_vector(3 downto 0);
signal dina,acum_out,douta: std_logic_vector(250 downto 0);
signal xdoub_in, ydoub_in: std_logic_vector(250 downto 0);
signal sel_s: std_logic_vector(2 downto 0);
signal sel_a_alu, sel_b_alu: std_logic_vector(3 downto 0);
signal a,b,c: std_logic_vector(250 downto 0);
signal ini_mul_s, ini_inv_s, done_mul_s, done_inv_s: std_logic;
signal sel_a,En_acum, En_xadd, En_yadd, En_xdoub, En_ydoub: std_logic;

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
constant salida_ram: std_logic_vector(3 downto 0):= "0000";
constant salida_acum: std_logic_vector(3 downto 0):= "0001";
constant x1: std_logic_vector(3 downto 0):= "0010";
constant y1: std_logic_vector(3 downto 0):= "0011";
constant x2: std_logic_vector(3 downto 0):= "0100";
constant y2: std_logic_vector(3 downto 0):= "0101";
constant x: std_logic_vector(3 downto 0):= "0110";
constant y: std_logic_vector(3 downto 0):= "0111";
constant d: std_logic_vector(3 downto 0):= "1000";

-------
begin

addra_s(2 downto 0) <= addra;
addra_s(3) <= '0';

ram_gen : ram16x251
  PORT MAP (addra_s,dina,clk,we,douta);
  
alu_gen: bec_alu port map(clk,reset,sel_s,a,b,c,ini_mul_s,ini_inv_s,done_mul_s,done_inv_s);
acumulador_gen: reg251 port map(c,acum_out,En_acum,clk);
reg_xoutadd_gen: reg251 port map(c,xout_add,En_xadd,clk);
reg_youtadd_gen: reg251 port map(c,yout_add,En_yadd,clk);
reg_xoutdoub_gen: reg251 port map(c,xout_doub,En_xdoub,clk);
reg_youtdoub_gen: reg251 port map(c,yout_doub,En_ydoub,clk);

------Bus de datos entrada RAM
with sel_a select
		dina<= acum_out when '0',--Acumulador		 
			 c when others; --salida alu
			 
--------------------Bus de datos entrada ALU
with sel_a_alu select
		a<= douta when "0000",--salida RAM	 
			 acum_out when "0001",--Salida Acumulador
			 x1in when "0010",--entrada x1
			 y1in when "0011",--entrada y1
			 x2in when "0100",--entrada x2
			 y2in when "0101",--entrada y2
			 xdoub_in when "0110",--x punto a doblar 
			 ydoub_in when "0111",--y punto a doblar 
			 din when others;--entada d
			 			 
with sel_b_alu select
		b <= douta when "0000",--salida RAM	 
			 acum_out when "0001",--Salida Acumulador
			 x1in when "0010",--entrada x1
			 y1in when "0011",--entrada y1
			 x2in when "0100",--entrada x2
			 y2in when "0101",--entrada y2
			 xdoub_in when "0110",--x punto a doblar 
			 ydoub_in when "0111",--y punto a doblar 
			 din when others;--entada d
			 
-----selecci�n de punto a doblar

with sel_doub select
		xdoub_in<= x1in when '0',--x1	 
			 x2in when others;--x2
			 
with sel_doub select
		ydoub_in<= y1in when '0',--y1	 
			 y2in when others;--y2
			 
------------------------------------FSM aritm�tica BEC coordenadas afines
--suma y doblado

fsm_aritbec: process(actual,init,done_mul_s,done_inv_s)		  

		begin

			case actual is

			when inicio =>				
				
				done<= '0'; sel_a<=ram_acum;sel_s<=load;
				we<='0';En_acum<='0';
				En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if init= '1' then
					if sel_op = '0' then--suma y doblado
						futuro <= s0;
					else
						futuro <= s100;--solo doblado
					end if;
				else
					futuro <= inicio;
				end if;
			
			when s0 =>	--Acum = x2 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x2;sel_b_alu<=y2;
				
				futuro <= s1;		
			
			when s1 =>	--Acum = x2 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x2;sel_b_alu<=y2;
				
				futuro <= s2;	
			
			when s2 =>	--T1 = x2 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x2;sel_b_alu<=y2;
				
				futuro <= s3;
			
			when s3 =>	--Acum = x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=y2;
				
				futuro <= s4;
			
			when s4 =>	--Acum = x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s5;
			
			when s5 =>	--Acum = x1 + x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s6;
			
			when s6 =>	--Acum = x1 + x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s7;
			
			when s7 =>	--T2=x1 + x1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=salida_acum;
				
				futuro <= s8;
			
			when s8 =>	--Acum = Acum * T1
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s9;
			
			when s9 =>	--Acum = Acum * T1
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s10;
			
			when s10 =>	--Acum = Acum * T1
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s12;
			
			when s12 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s13;
			
			when s13 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s14;
			
			when s14 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='1';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s15;
			
			when s15 =>	--Acum = Acum^-1 
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s17;
			
			when s17=>	--T3= inverso denominador
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s18;
			
			when s18=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=y1;
				
				futuro <= s19;
			
			when s19=>	--Acum = x1 + y1
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=y1;
				
				futuro <= s20;
			
			when s20=>	--Acum = (x1 + y1) (x2+y2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s21;
			
			when s21 =>	--Acum = (x1 + y1) (x2+y2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s22;
			
			when s22 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s24;
			
			when s24 =>	--T4 = (x1 + y1) (x2+y2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s25;
			
			when s25 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s26;
			
			when s26 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s27;
			
			when s27 =>	--T5= x1 + x2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s28;
			
			when s28 =>	--T5 = X1 + X2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s29;
			
			when s29 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s30;
			
			when s30 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s31;
			
			when s31 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s32;
			
			when s32 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s34;
			
			when s34 =>	--T6=parte 1 numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s35;
			
			when s35 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s36;
			
			when s36 =>	--Acum = y1 + y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s37;
			
			when s37 =>	--Acum = y1 + y2 + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s38;
			
			when s38 =>	--Acum = y1 + y2 + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s39;
			
			when s39 =>	--Acum = x2(y1 + y2 + 1)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s40;
			
			when s40 =>	--Acum = x2(y1 + y2 + 1)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s41;
				
			when s41 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s43;
			
			when s43 =>	--Almacena en T7
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=x2;
				
				futuro <= s44;
			
			when s44 =>	--y1y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s45;
			
			when s45 =>	--y1y2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s46;
			
			when s46 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s48;
			
			when s48 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s49;
			
			when s49 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s50;
			
			when s50 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s51;
			
			when s51 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s53;
			
			when s53 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s54;
			
			when s54 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s55;
			
			when s55 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s56;
			
			when s56 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_xadd<='1';
					futuro <= s57;
				else
					futuro <= s56;
				end if;
			
			when s57 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y1;
				
				futuro <= s58;
			-------------------------------------finaliza c�lculo de x3

			when s58 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=sqr;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y1;
				
				futuro <= s59;
			
			when s59 =>	--y1 + y1^2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=salida_acum;
				
				futuro <= s60;
				
			when s60 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=salida_acum;
				
				futuro <= s61;
			
			when s61 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s61_1;
			
			when s61_1 =>	--Almacena en T2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s61_2;
			
			when s61_2 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s62;
				
			when s62 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s63;
			
			when s63 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s65;
			
			when s65 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s66;
			
			when s66 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s67;
			
			when s67 =>	--calcula inverso denominador
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='1';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s68;
			
			when s68 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s70;
			
			when s70 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s71;
			
			when s71 =>	--y1 + y2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s72;
			
			when s72 =>	--y1 + y2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y1;sel_b_alu<=y2;
				
				futuro <= s72_1;
			
			when s72_1 =>	--y1 + y2 + T4
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s73;
			
			when s73 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s74;
			
			when s74 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s75;
			
			when s75 =>	--d(primera parte numerador)
				
				done<= '0';sel_a<=ram_alu;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s76;
			
			when s76 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s78;
				
			when s78 =>	--Almacena en T6
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=d;
				
				futuro <= s79;
				
			when s79 =>	--x1 + x2 + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=d;
				
				futuro <= s80;
			
			when s80 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=d;
				
				futuro <= s81;
			
			when s81 =>	--y2(x1+x2+1)
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s82;
			
			when s82 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s83;
			
			when s83 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s85;
			
			when s85 =>	--Almacena en T7
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y2;
				
				futuro <= s86;
			
			when s86 =>	--x1x2
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s87;
			
			when s87 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=x1;sel_b_alu<=x2;
				
				futuro <= s88;
			
			when s88 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s90;
			
			when s90 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s91;
			
			when s91 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s92;
			
			when s92 =>	--segunda parte numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s93;
			
			
			when s93 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
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
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s95;
			
			when s95 =>	--suma numerador
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s96;
			
			when s96 =>	--num/den
			
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s97;
			
			when s97 =>	--num/den
			
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_ram;
				
				futuro <= s98;
			
			when s98 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_yadd<='1';--Almacena y3
					futuro <= s99;
				else
					futuro <= s98;
				end if;
				
			when s99 =>	--fin de Madd
			
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s100;
-------------------------------------------fin suma de puntos

---------inicio doblado
			
			when s100 =>	--x^2
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s101;	
				
			when s101 =>	--almacena en memoria T1			
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s102;
			
			when s102 =>	--almacena en acumulador
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s103;
			
			when s103 =>	--T2 = x^4
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y;
				
				futuro <= s104;
			
			when s104 =>	--almacena en ram
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s105;
			
			when s105 =>	--T3=y^2
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y;sel_b_alu<=y;
				
				futuro <= s106;
			
			when s106 =>	--almacena en ram
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y;sel_b_alu<=y;
				
				futuro <= s107;
			
			when s107 =>	--almacena en acumulador
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y;sel_b_alu<=y;
				
				futuro <= s108;
			
			when s108 =>	--T4 = y^4
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y;
				
				futuro <= s109;
			
			when s109 =>	--T4 = y^4
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y;
				
				futuro <= s110;
			
			when s110 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=load;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=y;
				
				futuro <= s111;
			
			when s111 =>	--Acum = T1
				
				done<= '0';sel_a<=ram_alu;sel_s<=load;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=y;
				
				futuro <= s112;
				
			when s112 =>	--Acum = T1
				
				done<= '0';sel_a<=ram_alu;sel_s<=load;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s113;
			
			when s113 =>	--Acum = Acum + T3
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s114;
			
			when s114 =>	--Acum = Acum + T3
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s115;
			
			when s115 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s116;
			
			when s116 =>	--T6=acum 
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s117;		
			
			when s117 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s118;		
				
			when s118 =>	--Acum = Acum + T2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s119;
			
			when s119 =>	--Acum = Acum + T2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s120;
			
			when s120 =>	--Acum = Acum + T4
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s121;
			
			when s121 =>	--Acum = Acum + T4
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s122;
			
			when s122 =>	--Acum = Acum + d
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s123;
			
			when s123 =>	--Acum = Acum + d
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s124;
			
			when s124 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s125;
			
			when s125=>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='1';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s126;

			
			when s126=>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				if done_inv_s = '1' then
					En_acum<='1';
					futuro <= s127;
				else
					futuro <= s126;
				end if;
			
			when s127=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s128;
			
			when s128=>	--Almacena resultado en memoria T5
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s129;
			
			when s129=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s130;
			
			when s130=>	--Acum = T6
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s131;
			
			when s131=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s132;
			
			when s132=>	--Acum = Acum + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s133;
			
			when s133=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s134;
			
			when s134=>	--Acum = Acum * d
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s135;
			
			when s135=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s136;
			
			when s136=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s137;
				else 
					futuro <= s136;
				end if;
			
			when s137=>	--T7 = Acum
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s138;
			
			when s138=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='1';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s139;
				
				
			when s139=>	----Acum = Acum + y^2 (T3)
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s140;
			
			when s140=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s141;
			
			when s141=>	----Acum = Acum + y^4 (T4)
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s142;
			
			when s142=>	----Acum = Acum + y^4 (T4)
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s143;
			
			when s143=>	----Acum = Acum * T5
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s144;

			when s144=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s145;
			
			when s145=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s146;
				else 
					futuro <= s145;
				end if;
			
			when s146=>	--Xdoub = Acum + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s147;
			
			when s147=>	--Xdoub = Acum + 1 (fin c�lculo de xdoub)
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='1';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s148;
			--------------------------------inicia c�lculo de ydoub
			
			when s148=>	--Acum = T1 
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s149;
				
			when s149=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s150;
			
			when s150=>	--Acum = Acum + T2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s151;
			
			when s151=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s152;
			
			when s152=>	--Acum = Acum + T7
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s153;
			
			when s153=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				we<='0';En_acum<='1';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s154;
			
			when s154=>	----Acum = Acum * T5
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s155;

			when s155=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s156;
			
			when s156=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s157;
				else 
					futuro <= s156;
				end if;
			
			when s157=>	--ydoub = Acum + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s158;
			
			when s158=>	--
				
				done<= '1';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='1';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s159;
			
			when s159=>	--ydoub = Acum + 1 (fin c�lculo de ydoub y fin doblado)
				
				done<= '1';sel_a<=ram_acum;sel_s<=inc;
				we<='0';En_acum<='0';En_xadd<='0';En_yadd<='0';En_xdoub<='0';En_ydoub<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= inicio;
------------------------------------------Fin operaciones puntos BEC	
			end case;			

end process fsm_aritbec;

sincronismo : process(clk,futuro,reset)
	
begin
    	if(reset = '1') then		
      	actual <= inicio;				
      elsif rising_edge(clk) then						
			actual <= futuro;				
      end if;
end process sincronismo;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_components.all;

entity Mdouble is
    Port ( din,x1in,y1in: in  STD_LOGIC_VECTOR (250 downto 0);
           x2out,y2out: out  STD_LOGIC_VECTOR (250 downto 0);
           init,clk,reset: in  STD_LOGIC;
           done: out  STD_LOGIC);
end Mdouble;

architecture Behavioral of Mdouble is

type state_values is (inicio,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,
s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36,s37,
s38,s39,s40,s41,s42,s43,s44,s45,s46,s47,s48,s49,s50,s51,s52,s53,s54,s55,s56,s57,s58,s59);

signal actual, futuro: state_values;

signal wea: std_logic_vector(0 downto 0);
signal dina,acum_out,douta: std_logic_vector(250 downto 0);
signal addra,sel_s,sel_a_alu, sel_b_alu: std_logic_vector(2 downto 0);
signal a,b,c: std_logic_vector(250 downto 0);
signal ini_mul_s, ini_inv_s, done_mul_s, done_inv_s: std_logic;
signal En_acum, En_x2, En_y2,sel_a: std_logic;

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
constant x: std_logic_vector(2 downto 0):= "010";
constant y: std_logic_vector(2 downto 0):= "011";
constant d: std_logic_vector(2 downto 0):= "100";
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
reg_x3_gen: reg251 port map(c,x2out,En_x2,clk);
reg_y3_gen: reg251 port map(c,y2out,En_y2,clk);
------Bus de datos entrada RAM
with sel_a select
		dina<= acum_out when '0',--Acumulador		 
			 c when others; --salida alu
			 
--------------------Bus de datos entrada ALU
with sel_a_alu select
		a<= douta when "000",--salida RAM	 
			 acum_out when "001",--Salida Acumulador
			 x1in when "010",--entrada x
			 y1in when "011",--entrada y
			 din when others;--entada d
			 			 
with sel_b_alu select
		b<= douta when "000",--salida RAM	 
			 acum_out when "001",--Salida Acumulador
			 x1in when "010",--entrada x
			 y1in when "011",--entrada y
			 din when others;--entada d
			 		 
------------------------------------FSM doblado de puntos coordenadas afines
fsm_double: process(actual,init,done_mul_s,done_inv_s)		  

		begin

			case actual is

			when inicio =>				
				
				done<= '0'; sel_a<=ram_alu;sel_s<=load;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				if init= '1' then					
					futuro <= s0;
				else
					futuro <= inicio;
				end if;
			
			when s0 =>	--x^2
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='1';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s1;		
			when s1 =>	--almacena en memoria T1			
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s2;
			
			when s2 =>	--almacena en acumulador
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s3;
			
			when s3 =>	--T2 = x^4
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='1';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y;
				
				futuro <= s4;
			
			when s4 =>	--almacena en ram
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s5;
			
			when s5 =>	--T3=y^2
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='1';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y;sel_b_alu<=y;
				
				futuro <= s6;
			
			when s6 =>	--almacena en ram
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y;sel_b_alu<=y;
				
				futuro <= s7;
			
			when s7 =>	--almacena en acumulador
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=y;sel_b_alu<=y;
				
				futuro <= s8;
			
			when s8 =>	--T4 = y^4
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='1';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y;
				
				futuro <= s9;
			
			when s9 =>	--T4 = y^4
				
				done<= '0';sel_a<=ram_alu;sel_s<=sqr;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=y;
				
				futuro <= s10;
			
			when s10 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=load;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=y;
				
				futuro <= s11;
			
			when s11 =>	--Acum = T1
				
				done<= '0';sel_a<=ram_alu;sel_s<=load;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=y;
				
				futuro <= s12;
				
			when s12 =>	--Acum = T1
				
				done<= '0';sel_a<=ram_alu;sel_s<=load;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s13;
			
			when s13 =>	--Acum = Acum + T3
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s14;
			
			when s14 =>	--Acum = Acum + T3
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s15;
			
			when s15 =>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s16;
			
			when s16 =>	--T6=acum 
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='1';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s17;		
			
			when s17 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s18;		
				
			when s18 =>	--Acum = Acum + T2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s19;
			
			when s19 =>	--Acum = Acum + T2
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s20;
			
			when s20 =>	--Acum = Acum + T4
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s21;
			
			when s21 =>	--Acum = Acum + T4
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s22;
			
			when s22 =>	--Acum = Acum + d
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s23;
			
			when s23 =>	--Acum = Acum + d
				
				done<= '0';sel_a<=ram_alu;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s24;
			
			when s24 =>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s25;
			
			when s25=>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='1';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s26;

			
			when s26=>	--
				
				done<= '0';sel_a<=ram_alu;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				if done_inv_s = '1' then
					En_acum<='1';
					futuro <= s27;
				else
					futuro <= s26;
				end if;
			
			when s27=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s28;
			
			when s28=>	--Almacena resultado en memoria T5
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='1';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s29;
			
			when s29=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inverso;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s30;
			
			when s30=>	--Acum = T6
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s31;
			
			when s31=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s32;
			
			when s32=>	--Acum = Acum + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s33;
			
			when s33=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s34;
			
			when s34=>	--Acum = Acum * d
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s35;
			
			when s35=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				futuro <= s36;
			
			when s36=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T6;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=d;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s37;
				else 
					futuro <= s36;
				end if;
			
			when s37=>	--T7 = Acum
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s38;
			
			when s38=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='1';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s39;
				
			when s39=>	----Acum = Acum + y^2 (T3)
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s40;
			
			when s40=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T3;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s41;
			
			when s41=>	----Acum = Acum + y^4 (T4)
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s42;
			
			when s42=>	----Acum = Acum + y^4 (T4)
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T4;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s43;
			
			when s43=>	----Acum = Acum * T5
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s44;

			when s44=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s45;
			
			when s45=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s46;
				else 
					futuro <= s45;
				end if;
			
			when s46=>	--X3 = Acum + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s47;
			
			when s47=>	--X2 = Acum + 1 (fin cálculo de x2)
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x2<='1';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s48;
			--------------------------------inicia cálculo de y2
			
			when s48=>	--Acum = T1 
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s49;
				
			when s49=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=load;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T1;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s50;
			
			when s50=>	--Acum = Acum + T2
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s51;
			
			when s51=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T2;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s52;
			
			when s52=>	--Acum = Acum + T7
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s53;
			
			when s53=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=suma;
				wea(0)<='0';En_acum<='1';En_x2<='0';En_y2<='0';
				addra<=T7;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s54;
			
			when s54=>	----Acum = Acum * T5
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s55;

			when s55=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='1';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				futuro <= s56;
			
			when s56=>	--
				
				done<= '0';sel_a<=ram_acum;sel_s<=mul;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_ram;sel_b_alu<=salida_acum;
				
				if done_mul_s = '1' then
					En_acum<='1';
					futuro <= s57;
				else 
					futuro <= s56;
				end if;
			
			when s57=>	--y2 = Acum + 1
				
				done<= '0';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s58;
			
			when s58=>	--
				
				done<= '1';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='1';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= s59;
			
			when s59=>	--y2 = Acum + 1 (fin cálculo de y2 y fin de Mdouble)
				
				done<= '1';sel_a<=ram_acum;sel_s<=inc;
				wea(0)<='0';En_acum<='0';En_x2<='0';En_y2<='0';
				addra<=T5;
				ini_mul_s<='0';ini_inv_s<='0';
				sel_a_alu<=salida_acum;sel_b_alu<=salida_acum;
				
				futuro <= inicio;
				
			end case;	
			
end process fsm_double;

sincronismo : process(clk,futuro,reset)
	
begin
    	if(reset = '1') then		
      	actual <= inicio;				
      elsif rising_edge(clk) then						
			actual <= futuro;				
      end if;
end process sincronismo;


end Behavioral;


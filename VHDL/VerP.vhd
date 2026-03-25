--módulo verificación punto escalar
--Autor: Javier Castaño 2015
-----------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_components.all;

entity VerP is
    Port ( x1in,y1in,din : in  STD_LOGIC_VECTOR (250 downto 0);
           init,clk,reset : in  STD_LOGIC;
			  done : out  STD_LOGIC;
           ispoint : out  STD_LOGIC);
end VerP;

architecture Behavioral of VerP is

type state_values is (inicio,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9);	
				
signal actual, futuro: state_values;

signal acum_out,t1_s,t2_s,compeq,eq1,eq2: std_logic_vector(250 downto 0);
signal sel_s: std_logic_vector(1 downto 0);
signal sel_a_alu, sel_b_alu: std_logic_vector(2 downto 0);
signal a,b,c: std_logic_vector(250 downto 0);
signal ini_mul_s, done_mul_s: std_logic;
signal En_acum,En_eq1, En_eq2,En_t1,En_t2: std_logic;

---Constantes para operaciones de la ALU
constant suma: std_logic_vector(1 downto 0) := "00";
constant sqr: std_logic_vector(1 downto 0) := "01";
constant mul: std_logic_vector(1 downto 0) := "10";
constant load: std_logic_vector(1 downto 0) := "11";

--Contantes para bus de entrada ALU
constant acum: std_logic_vector(2 downto 0):= "000";
constant d: std_logic_vector(2 downto 0):= "001";
constant x: std_logic_vector(2 downto 0):= "010";
constant y: std_logic_vector(2 downto 0):= "011";
constant t1: std_logic_vector(2 downto 0):= "100";
constant t2: std_logic_vector(2 downto 0):= "101";
-------

begin

compeq <= eq1 xor eq2;

with compeq select ispoint <=
	'1' when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	'0' when others;
	
alu_gen: bec_alu_2 port map(clk,reset,sel_s,a,b,c,ini_mul_s,done_mul_s);
acumulador_gen: reg251 port map(c,acum_out,En_acum,clk);
reg_eq1_gen: reg251 port map(c,eq1,En_eq1,clk);
reg_eq2_gen: reg251 port map(c,eq2,En_eq2,clk);
reg_t1_gen: reg251 port map(c,t1_s,En_t1,clk);
reg_t2_gen: reg251 port map(c,t2_s,En_t2,clk);

--------------------Bus de datos entrada ALU
with sel_a_alu select
		a<= acum_out when "000",--acumulador		 
			 din when "001",-- d
			 x1in when "010",--entrada x
			 y1in when "011",--entrada y
			 t1_s when "100",--registro T1
			 t2_s when others;--registro T2 
			 		
with sel_b_alu select
		b<= acum_out when "000",--acumulador		 
			 din when "001",-- d
			 x1in when "010",--entrada x
			 y1in when "011",--entrada y
			 t1_s when "100",--registro T1
			 t2_s when others;--registro T2 
			 
----------------------------------FSM verificaci�n de puntos
fsm_vp: process(actual,init,done_mul_s)		  

		begin

			case actual is

			when inicio =>				
				
				done<= '0';sel_s<=load;
				En_acum<='0';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				if init= '1' then					
					futuro <= s0;
				else
					futuro <= inicio;
				end if;
			
			when s0 => --Acum = X^2				
				
				done<= '0';sel_s<=sqr;
				En_acum<='1';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=x;sel_b_alu<=y;
				
				futuro <= s1;
			
			when s1 => --T1 = Acum + X				
				
				done<= '0';sel_s<=suma;
				En_acum<='0';En_eq1<='0';En_eq2<='0';
				En_t1<='1';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=x;sel_b_alu<=acum;
				
				futuro <= s2;
			
			when s2 => --Acum = Y^2				
				
				done<= '0';sel_s<=sqr;
				En_acum<='1';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=y;sel_b_alu<=acum;
				
				futuro <= s3;
			
			when s3 => --T2 = Acum + Y			
				
				done<= '0';sel_s<=suma;
				En_acum<='0';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='1';
				ini_mul_s<='0';
				sel_a_alu<=y;sel_b_alu<=acum;
				
				futuro <= s4;
			
			when s4 => --Acum = T2 + T1			
				
				done<= '0';sel_s<=suma;
				En_acum<='1';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=t1;sel_b_alu<=t2;
				
				futuro <= s5;
			
			when s5 => --Acum = Acum * d		
				
				done<= '0';sel_s<=mul;
				En_acum<='0';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='1';
				sel_a_alu<=d;sel_b_alu<=acum;
				
				futuro <= s6;
			
			when s6 => --Acum = Acum * d		
				
				done<= '0';sel_s<=mul;
				En_acum<='0';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=d;sel_b_alu<=acum;
				
				if done_mul_s = '1' then
					En_eq1<='1';
					futuro <= s7;					
				else
					futuro <= s6;
				end if;
			
			when s7 => --t1 * t2
				
				done<= '0';sel_s<=mul;
				En_acum<='0';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='1';
				sel_a_alu<=t1;sel_b_alu<=t2;
				futuro <= s8;			
			
			when s8 => --t1 * t2
				
				done<= '0';sel_s<=mul;
				En_acum<='0';En_eq1<='0';En_eq2<='0';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=t1;sel_b_alu<=t2;
				
				if done_mul_s = '1' then
					futuro <= s9;					
				else
					futuro <= s8;
				end if;
			
			when s9 => --	Almacena Eq2
				
				done<= '1';sel_s<=mul;
				En_acum<='0';En_eq1<='0';En_eq2<='1';
				En_t1<='0';En_t2<='0';
				ini_mul_s<='0';
				sel_a_alu<=t1;sel_b_alu<=t2;
				
				futuro <= inicio;
				
			end case;
			
end process fsm_vp;

sincronismo : process(clk,futuro,reset)
	
begin
    	if(reset = '1') then		
      	actual <= inicio;				
      elsif rising_edge(clk) then						
			actual <= futuro;				
      end if;
end process sincronismo;

end Behavioral;

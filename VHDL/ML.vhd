--módulo top
--control de multiplicación escalar
--Montgomery ladder coordenadas proyectivas
--Autor: Javier Castaño 2015


-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_components.all;


entity ML is
    Port ( k,x,y,d : in  STD_LOGIC_VECTOR (250 downto 0);
           kx,ky : out  STD_LOGIC_VECTOR (250 downto 0);
		   clk,init,reset : in  STD_LOGIC;
           done : out  STD_LOGIC);
end ML;

architecture Behavioral of ML is

type state_values is (inicio,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9);	
				
signal actual, futuro: state_values;

signal En_P1x, En_P1y: std_logic;
signal En_P2x, En_P2y: std_logic;
signal ki,init_ml,sel_op,sel_doub,done_arit,en_shift,load: std_logic;
signal i: unsigned(7 downto 0);


signal ks,P1x_s, P1y_s,P2x_s,P2y_s: std_logic_vector(250 downto 0);
signal P1x_out, P1y_out,P2x_out,P2y_out: std_logic_vector(250 downto 0);
signal xadd,yadd,xdoub,ydoub: std_logic_vector(250 downto 0);
signal sel_in_P1x, sel_in_P1y,sel_in_P2x,sel_in_P2y : std_logic_vector(1 downto 0);

begin


aritbec_gen: AritBEC port map(clk,reset,d,P1x_out,P1y_out,P2x_out,P2y_out,xadd,yadd,xdoub,
ydoub,init_ml,sel_op,sel_doub,done_arit);

reg_P1x_gen: reg251 port map(P1x_s,P1x_out,En_P1x,clk);
reg_P1y_gen: reg251 port map(P1y_s,P1y_out,En_P1y,clk);
reg_P2x_gen: reg251 port map(P2x_s,P2x_out,En_P2x,clk);	
reg_P2y_gen: reg251 port map(P2y_s,P2y_out,En_P2y,clk);

---selectores de entrada a P1
with sel_in_P1x select
		P1x_s <= x when "00",--entrada Px 
			 xadd when "01",--salida Madd y
			 xdoub when others;--salida Mdouble y

with sel_in_P1y select
		P1y_s <= y when "00",--entrada Py 
			 yadd when "01",--salida Madd y
			 ydoub when others;--salida Mdouble y
			 
---selectores de entrada a P2
with sel_in_P2x select
		P2x_s <= x when "00",--entrada Px 
			 xadd when "01",--salida Madd y
			 xdoub when others;--salida Mdouble y

with sel_in_P2y select
		P2y_s <= y when "00",--entrada Py 
			 yadd when "01",--salida Madd y
			 ydoub when others;--salida Mdouble y
-------------------------------------------------------------

kx <= P1x_out;--salida algoritmo ML
ky <= P1y_out;		 
----------------------------------FSM Montgomery Ladder
fsm_ml: process(actual,init,done_arit)		  

		--variable i: integer range 0 to 250;
		
		begin

			case actual is

			when inicio =>				
				
				En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="00";sel_in_P2y<="00";
				sel_op<='0';sel_doub<='0';
				en_shift<='0';load<='0';
				
				init_ml <= '0';				
				done<= '0'; 
												
				if init= '1' then					
					futuro <= s0;
				else
					futuro <= inicio;
				end if;
			
			when s0 => --P1 = P				
				
				
				En_P1x <= '1';En_P1y <= '1';En_P2x <= '0';En_P2y <= '0';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="00";sel_in_P2y<="00";
				sel_op<='0';sel_doub<='0';
				en_shift<='0';load<='1';
				
				init_ml <= '0';
				
				done<= '0'; 
				
				futuro <= s1;						
			
			when s1 => --P2 = 2P1 = 2P			
				
							
				En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="10";sel_in_P2y<="10";
				sel_op<='1';sel_doub<='0';
				en_shift<='0';load<='0';
				
				init_ml <= '0';
				
				done<= '0'; 
				
				futuro <= s2;
				
			
			when s2 => --P2 = 2P1 = 2P						
				
								
				En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="10";sel_in_P2y<="10";
				sel_op<='1';sel_doub<='0';
				en_shift<='0';load<='0';
				
				init_ml <= '1';
				
				done<= '0'; 
				
				futuro <= s3;
				
			when s3 => --			
				
				
				
				En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="10";sel_in_P2y<="10";
				sel_op<='1';sel_doub<='0';
				en_shift<='0';load<='0';
				
				init_ml <= '0';
				
				done<= '0'; 
				
				if done_arit = '1' then	
					futuro <= s4;
				else
				   futuro <= s3;
				 end if;
				
			when s4 => --almacena P2		
				
				En_P1x <= '0';En_P1y <= '0';En_P2x <= '1';En_P2y <= '1';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="10";sel_in_P2y<="10";
				sel_op<='1';sel_doub<='0';
				en_shift<='0';load<='0';
				
				init_ml <= '0';
				
				done<= '0'; 
				
				futuro <= s5;	
				
			when s5 => --inicio de evaluaci�n del escalar		
				
				En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="10";sel_in_P2y<="10";
				sel_op<='0';sel_doub<='0';
				en_shift<='1';load<='0';
				
				init_ml <= '0';
				
				done<= '0'; 
				
				futuro <= s6;	
			
			when s6 => --evalua escalar
			
				done<= '0';		
				
				if ki = '1' then--P1 = P1 + P2, P2 = 2P2
					En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
					sel_in_P1x<="01";sel_in_P1y<="01";sel_in_P2x<="10";sel_in_P2y<="10";	
					sel_op<='0';sel_doub<='1';
					en_shift<='0';load<='0';
					
					init_ml <= '1';
					futuro <= s7;					
				else --P2 = P1 + P2, P1 = 2P1
					En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
					sel_in_P1x<="10";sel_in_P1y<="10";sel_in_P2x<="01";sel_in_P2y<="01";
					sel_op<='0';sel_doub<='0';
					en_shift<='0';load<='0';
					
					init_ml <= '1';
					futuro <= s7;
					
				end if;
			
			when s7 => --espera fin			
										
				init_ml <= '0';
				en_shift<='0';load<='0';
				
				done<= '0'; 
				
				if done_arit = '1' then
					futuro <= s8;
				else
					futuro <= s7;
				end if;
			
			when s8 => 
			
				en_shift<='0';load<='0';
				
				if ki = '1' then
					En_P2x <= '1';En_P2y <= '1';--Almacena P2 = 2P2
					En_P1x <= '0';En_P1y <= '0';
				else
					En_P1x <= '1';En_P1y <= '1';--Almacena P1 = 2P1
					En_P2x <= '0';En_P2y <= '0';
				end if;
				
				futuro <= s9;
				
			when s9 => --evalua fin algoritmo		
				
				En_P1x <= '0';En_P1y <= '0';En_P2x <= '0';En_P2y <= '0';
				sel_in_P1x<="00";sel_in_P1y<="00";sel_in_P2x<="00";sel_in_P2y<="00";
				sel_op<='0';sel_doub<='0';
							
				init_ml <= '0';
				
				if ks = X"0000000000000000000000000000000000000000000000000000000000000000" then
					 done<= '1';--fin algoritmo
					futuro <= inicio;
				else
					done<= '0';
					futuro <= s5;
				end if;
				
			end case;
			
end process fsm_ml;

sincronismo : process(clk,futuro,reset)
	
begin
    	if(reset = '1') then		
      	actual <= inicio;				
      elsif rising_edge(clk) then						
			actual <= futuro;				
      end if;
end process sincronismo;
-------------------------------------
------------------desplazamiento de k y generacion del bit ki
shift_reg: process(clk,en_shift,load)
begin
if rising_edge(clk) then
	if load='1' then
		ks<=k;--carga k
	elsif en_shift = '1' then
		ks(250 downto 0) <= ks(249 downto 0) & '0';
	end if;
end if;
ki<=ks(250);
end process shift_reg;

end Behavioral;


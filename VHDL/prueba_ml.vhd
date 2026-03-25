library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_components.all;

entity prueba_ml is
    Port ( clk, reset : in  STD_LOGIC;
           d,k,x,y: in  STD_LOGIC_VECTOR (250 downto 0);
           kx,ky : out  STD_LOGIC_VECTOR (250 downto 0);
			  init : in  STD_LOGIC;
           done,ispoint,done_ml_out,done_verp_out : out  STD_LOGIC);
end prueba_ml;

architecture Behavioral of prueba_ml is

type state_values is (inicio,s0,s1,s2,s3,s4);	
				
signal actual, futuro: state_values;

signal xout_ml,yout_ml: std_logic_vector(250 downto 0);
signal init_ml,done_ml,init_verip,done_verip: std_logic;

begin

ml_gen: ML port map(k,x,y,d,xout_ml,yout_ml,clk,init_ml,reset,done_ml);
verp_gen: VerP port map(xout_ml,yout_ml,d,init_verip,clk,reset,done_verip,ispoint);

kx<=xout_ml;
ky<=yout_ml;
done_ml_out<=done_ml;
done_verp_out<=done_ml;
------------------------------------FSM 
fsm_prueba: process(actual,init,done_ml,done_verip)		  

		begin

			case actual is

			when inicio =>				
				
				init_ml<='0';init_verip<='0';
				done<='0';				
				
				if init= '1' then					
					futuro <= s0;
				else
					futuro <= inicio;
				end if;
			
			when s0 =>
				
				init_ml<='1';init_verip<='0';
				done<='0';			
				
				futuro <= s1;
		
			when s1 =>
			
				init_ml<='0';init_verip<='0';
				done<='0';	
				
				if done_ml = '1' then					
					futuro <= s2;
				else
					futuro <= s1;
				end if;
				
			when s2 =>
				
				init_ml<='0';init_verip<='1';
				done<='0';				
				futuro <= s3;
			
			when s3 =>
				
				init_ml<='0';init_verip<='0';
				done<='0';	
				
				if done_verip= '1' then					
					futuro <= s4;
				else
					futuro <= s3;
				end if;
			
			when s4 =>
				
				init_ml<='0';init_verip<='0';
				done<='1';				
				futuro <= inicio;
				
			end case;			

end process fsm_prueba;

sincronismo : process(clk,futuro,reset)
	
begin
    	if(reset = '1') then		
      	actual <= inicio;				
      elsif rising_edge(clk) then						
			actual <= futuro;				
      end if;
end process sincronismo;

end Behavioral;
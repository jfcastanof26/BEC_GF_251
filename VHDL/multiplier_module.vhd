----Multiplicación GF(2^251) 
--
--Autor: Javier Castaño 2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplier_module is

port(	clk,reset : in std_logic;
		start : in std_logic;
		operand1_port : in std_logic_vector(250 downto 0);
		operand2_port : in std_logic_vector(250 downto 0);
		result_port : out std_logic_vector(250 downto 0);
		ready : out std_logic);	

end multiplier_module;

architecture Behavioral of multiplier_module is
constant reduction_polynomial: std_logic_vector(250 downto 0) := (0=>'1', 2=>'1', 4=>'1', 7=>'1', others=>'0');
begin

process(clk,reset,start)
variable operand1 : std_logic_vector(250 downto 0);
variable operand2 : std_logic_vector(250 downto 0);
variable operandr : std_logic_vector(250 downto 0);
variable operandb : std_logic_vector(250 downto 0);
variable result : std_logic_vector(250 downto 0);
variable temp : std_logic:='0';
variable p : integer range 0 to 250:= 0;


begin

	if reset = '1' then
		temp := '0';
		result := (others=>'0');
		p := 0;
		ready <= '0';
	elsif rising_edge(clk) then
	
		if start='1' and temp ='0' then
			temp := '1';
			operand1 := operand1_port;
			operand2 := operand2_port;
			operandr := (others => '0');
			operandb := (others => '0');
			result := (others=>'0');
			p := 0;
			ready <= '0';
			
		elsif start='0' and temp ='1' then				
			
			if result(250) = '1' then operandr := reduction_polynomial; 
			else operandr := (others=>'0');
			end if;
				
			if operand2(250-p) = '1' then operandb := operand1; 
			else operandb := (others=>'0'); 
			end if;
			
			result := (result(249 downto 0) & '0') xor operandr xor operandb ; 			
			p := p+1;							
							
			if (p = 251) then 					
				temp := '0';
				ready <= '1';
			end if;
				
		elsif start='0' and temp ='0' then	
			p:= 0;
			ready <= '0';
			
		end if;
		
	end if;		


	result_port <= result;
	
end process;
end Behavioral;
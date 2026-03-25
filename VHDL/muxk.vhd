-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.aes_package.all;


entity muxk is	
	port(w0,w1,w2,w3: in std_logic_vector(255 downto 0);
		  f: out std_logic_vector(255 downto 0);
		  s: in std_logic_vector(1 downto 0)
		  );
end muxk;

architecture muxk_arch of muxk is

begin

	with s select
		f<= w0 when "00",---sumador		 
			 w1 when "01",--multiplicador
			 w2 when "10",--squaring
			 w3 when others;---inversor			 

end muxk_arch;
--Testbencho módulo verificación punto escalar
--Autor: Javier Castaño 2015


-----------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY VerP_tb IS
END VerP_tb;
 
ARCHITECTURE behavior OF VerP_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT VerP
    PORT(
         x1in : IN  std_logic_vector(250 downto 0);
         y1in : IN  std_logic_vector(250 downto 0);
         din : IN  std_logic_vector(250 downto 0);
         init : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         done : OUT  std_logic;
         ispoint : OUT  std_logic
        );
    END COMPONENT;
    
--Inputs
   signal x1in : std_logic_vector(250 downto 0) := (others => '0');
   signal y1in : std_logic_vector(250 downto 0) := (others => '0');
   signal din : std_logic_vector(250 downto 0) := (others => '0');
   signal init : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

	signal x1in_s: std_logic_vector(255 downto 0);
	signal y1in_s: std_logic_vector(255 downto 0);
	signal din_s: std_logic_vector(255 downto 0);
	
 	--Outputs
   signal done, ispoint : std_logic;
   
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	x1in <= x1in_s(250 downto 0);
	y1in <= y1in_s(250 downto 0);	
	din <= din_s(250 downto 0);
	-- Instantiate the Unit Under Test (UUT)
	
   uut: VerP PORT MAP (
          x1in => x1in,
          y1in => y1in,
          din => din,
          init => init,
          clk => clk,
          reset => reset,
          done => done,
			 ispoint => ispoint
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for clk_period*10;

      init <= '0';
		reset <= '0';		
			
		wait for clk_period*10;

      init <= '1';
		reset <= '0';
		
		y1in_s <= X"06C821DD3B5EA51E6F6D1E9AB702ECC9B252C989A2A5AB6D7A482842EFA71F7C";
		x1in_s <= X"029FFB6AFFF41641AD7FCF41A36E089874B76CBA8939F493C8AC8793D8AD518A";
		
		--x1in_s <= 	X"0000000000000000000000000000000000000000000000000000000000000001";
		--y1in_s <= 	X"0000000000000000000000000000000000000000000000000000000000000001";

		din_s <=  X"0000000000000000000000000000000000000000000000000240100000000001";
		
		wait for clk_period*10;

      init <= '0';
		reset <= '0';

      wait;
   end process;

END;
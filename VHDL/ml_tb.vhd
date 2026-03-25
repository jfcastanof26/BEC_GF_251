----Testbench
--control de multiplicación escalar
--Montgomery ladder coordenadas proyectivas
--Autor: Javier Castaño 2015



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY ml_tb IS
END ml_tb;
 
ARCHITECTURE behavior OF ml_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ML
    PORT(
         k : IN  std_logic_vector(250 downto 0);
         x : IN  std_logic_vector(250 downto 0);
         y : IN  std_logic_vector(250 downto 0);
         d : IN  std_logic_vector(250 downto 0);
         kx : OUT  std_logic_vector(250 downto 0);
         ky : OUT  std_logic_vector(250 downto 0);
			clk : IN  std_logic;
         init : IN  std_logic;
         reset : IN  std_logic;
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal k : std_logic_vector(250 downto 0) := (others => '0');
   signal x : std_logic_vector(250 downto 0) := (others => '0');
   signal y : std_logic_vector(250 downto 0) := (others => '0');
   signal d : std_logic_vector(250 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal init : std_logic := '0';
   signal reset : std_logic := '0';
	
	signal k_s: std_logic_vector(255 downto 0);
	signal x_s: std_logic_vector(255 downto 0);
	signal y_s: std_logic_vector(255 downto 0);
	signal d_s: std_logic_vector(255 downto 0);
 	--Outputs
   signal kx : std_logic_vector(250 downto 0);
   signal ky : std_logic_vector(250 downto 0);
   signal done : std_logic;
	
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	k <= k_s(250 downto 0);
	x <= x_s(250 downto 0);
	y <= y_s(250 downto 0);
	d <= d_s(250 downto 0);
	
	-- Instantiate the Unit Under Test (UUT)
   uut: ML PORT MAP (
          k => k,
          x => x,
          y => y,
          d => d,
          kx => kx,
          ky => ky,
			 clk => clk,
          init => init,
          reset => reset,
          done => done
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
		
		k_s <= X"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
		
		x_s <= X"06C821DD3B5EA51E6F6D1E9AB702ECC9B252C989A2A5AB6D7A482842EFA71F7C";
		y_s <= X"029FFB6AFFF41641AD7FCF41A36E089874B76CBA8939F493C8AC8793D8AD518A";
		
		d_s <=  X"0000000000000000000000000000000000000000000000000240100000000001";
		
		wait for clk_period*10;

      init <= '0';
		reset <= '0';

      wait until done = '1';
		
   end process;

END;

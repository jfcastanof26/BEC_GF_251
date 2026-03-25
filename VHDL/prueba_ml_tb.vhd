--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:22:25 03/18/2015
-- Design Name:   
-- Module Name:   C:/Users/Biomedica/Desktop/BEC/bec_proc/prueba_ml_tb.vhd
-- Project Name:  bec_proc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: prueba_ml
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY prueba_ml_tb IS
END prueba_ml_tb;
 
ARCHITECTURE behavior OF prueba_ml_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT prueba_ml
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         d : IN  std_logic_vector(250 downto 0);
         k : IN  std_logic_vector(250 downto 0);
         x : IN  std_logic_vector(250 downto 0);
         y : IN  std_logic_vector(250 downto 0);
         kx : OUT  std_logic_vector(250 downto 0);
         ky : OUT  std_logic_vector(250 downto 0);
         init : IN  std_logic;
         done : OUT  std_logic;
         ispoint : OUT  std_logic;
			done_ml_out : OUT  std_logic;
			done_verp_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal d : std_logic_vector(250 downto 0) := (others => '0');
   signal k : std_logic_vector(250 downto 0) := (others => '0');
   signal x : std_logic_vector(250 downto 0) := (others => '0');
   signal y : std_logic_vector(250 downto 0) := (others => '0');
   signal init : std_logic := '0';

	signal k_s: std_logic_vector(255 downto 0);
	signal x_s: std_logic_vector(255 downto 0);
	signal y_s: std_logic_vector(255 downto 0);
	signal d_s: std_logic_vector(255 downto 0);
	
 	--Outputs
   signal kx : std_logic_vector(250 downto 0);
   signal ky : std_logic_vector(250 downto 0);
   signal done : std_logic;
   signal ispoint : std_logic;
	signal done_ml_out : std_logic;
	signal done_verp_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	k <= k_s(250 downto 0);
	x <= x_s(250 downto 0);
	y <= y_s(250 downto 0);
	d <= d_s(250 downto 0);
	
	-- Instantiate the Unit Under Test (UUT)
   uut: prueba_ml PORT MAP (
          clk => clk,
          reset => reset,
          d => d,
          k => k,
          x => x,
          y => y,
          kx => kx,
          ky => ky,
          init => init,
          done => done,
          ispoint => ispoint,
			 done_ml_out => done_ml_out,
			 done_verp_out => done_verp_out
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
      wait for clk_period*10;

      init <= '0';
		reset <= '0';		
			
		wait for clk_period*10;

      init <= '1';
		reset <= '0';
		
		--x1in_s <= X"0000000000000000000000000000000000000000000000000000000000000001";
		--y1in_s <= X"0000000000000000000000000000000000000000000000000000000000000001";
		
		k_s <= X"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
		x_s <= X"06C821DD3B5EA51E6F6D1E9AB702ECC9B252C989A2A5AB6D7A482842EFA71F7C";
		y_s <= X"029FFB6AFFF41641AD7FCF41A36E089874B76CBA8939F493C8AC8793D8AD518A";
		
		d_s <=  X"0000000000000000000000000000000000000000000000000240100000000001";
		
		wait for clk_period*10;

      init <= '0';
		reset <= '0';
		
      wait;
   end process;

END;

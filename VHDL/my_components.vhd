library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.aes_package.all;

package my_components is

component ML is
    Port ( k,x,y,d : in  STD_LOGIC_VECTOR (250 downto 0);
           kx,ky : out  STD_LOGIC_VECTOR (250 downto 0);
			  clk,init,reset : in  STD_LOGIC;
           done : out  STD_LOGIC);
end component;

component AritBEC is
    Port ( clk, reset : in  STD_LOGIC;
           din,x1in,y1in,x2in,y2in : in  STD_LOGIC_VECTOR (250 downto 0);
           xout_add,yout_add,xout_doub,yout_doub : out  STD_LOGIC_VECTOR (250 downto 0);
			  init, sel_op,sel_doub : in  STD_LOGIC;
           done : out  STD_LOGIC);
end component;

component VerP is
    Port ( x1in,y1in,din : in  STD_LOGIC_VECTOR (250 downto 0);
           init,clk,reset : in  STD_LOGIC;
			  done : out  STD_LOGIC;
           ispoint : out  STD_LOGIC);
end component;

---------------------------------------------------------
component MAdd is
    Port ( clk, reset : in  STD_LOGIC;
           din,x1in,y1in,x2in,y2in : in  STD_LOGIC_VECTOR (250 downto 0);
           x3out,y3out : out  STD_LOGIC_VECTOR (250 downto 0);
			  init : in  STD_LOGIC;
           done : out  STD_LOGIC);
end component;

component Mdouble is
    Port ( din,x1in,y1in: in  STD_LOGIC_VECTOR (250 downto 0);
           x2out,y2out: out  STD_LOGIC_VECTOR (250 downto 0);
           init,clk,reset: in  STD_LOGIC;
           done: out  STD_LOGIC);
end component;
---------------------------------------------------------
COMPONENT ram16x251
  PORT (
    a : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(250 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(250 DOWNTO 0) 
  );
END COMPONENT;

component bec_alu is
    Port (clk, reset: in std_logic;
			 sel: in std_logic_vector(2 downto 0);
			  a,b : in  STD_LOGIC_VECTOR (250 downto 0);
           c : out  STD_LOGIC_VECTOR (250 downto 0);
           ini_mul, ini_inv : in  STD_LOGIC;
           done_mul, done_inv : out  STD_LOGIC);
end component;

component bec_alu_2 is
    Port (clk, reset: in std_logic;
			 sel: in std_logic_vector(1 downto 0);
			  a,b : in  STD_LOGIC_VECTOR (250 downto 0);
           c : out  STD_LOGIC_VECTOR (250 downto 0);
           ini_mul : in  STD_LOGIC;
           done_mul : out  STD_LOGIC);
end component;

component sumador is
    Port ( a,b : in  STD_LOGIC_VECTOR (250 downto 0);
           c : out  STD_LOGIC_VECTOR (250 downto 0));
end component;

component control is
 Port (Clk     : in std_logic;--clock
       Res		: in std_logic;--reset general
		 TXD     : out std_logic;--RS232 TX 
       full		: out std_logic;
		 RXD     : in std_logic);
end component;

component multiplier_module is

port(	clk,reset : in std_logic;
		start : in std_logic;
		operand1_port : in std_logic_vector(250 downto 0);
		operand2_port : in std_logic_vector(250 downto 0);
		result_port : out std_logic_vector(250 downto 0);
		ready : out std_logic);	

end component;

component squaring_module is
    Port ( z : in  std_logic_vector (250 downto 0);
           z_2 : out  std_logic_vector (250 downto 0));
end component;

component itmia is
    Port ( clk,reset,start : std_logic;
           ready : out  std_logic;
           z : in  std_logic_vector (250 downto 0);
           inv_z : out  std_logic_vector (250 downto 0));
end component;

component fifo is
	generic(
		DEPTH : natural := 32;
		WIDTH : natural := 8
	);
	port(
		clk : in std_logic;                           -- clock input
		aclr : in std_logic := '1';                   -- active low asynchronous clear
		sclr : in std_logic := '0';                   -- active high synchronous clear
		bytes_in: in s_vector;
		D : in std_logic_vector(WIDTH -1 downto 0);   -- Data input
		wreq : in std_logic;                          -- write request
		bytes_out: out s_vector;
		Q : out std_logic_vector(WIDTH -1 downto 0);  -- Data output
		rreq : in std_logic;                          -- read request
		empty,                                        -- FIFO is empty		                                       -- FIFO is half full
		full : out std_logic                          -- FIFO is full
	);
end component;

----------------------------------------------
--UART
-----------------------------------------------

component uart is
    Port (
        Clk     : in std_logic;-- main clock
        Reset_n : in std_logic;-- main reset
        TXD     : out std_logic;-- RS232 TX data
        RXD     : in std_logic;-- RS232 RX data
        ck_div  : in std_logic_vector(15 downto 0);        
        --ck_div = F(clk) / ( baud_rate* 3)
        CE_N    : in std_logic;-- chip enable
        WR_N    : in std_logic;-- write enable
        RD_N    : in std_logic;-- read enable
        A0      : in std_logic;-- 0 - Rx/TX data reg; 1 - status reg
        D_IN    : in std_logic_vector(7 downto 0);
        D_OUT   : out std_logic_vector(7 downto 0);
        RX_full     : out std_logic;
        TX_busy_n   : out std_logic
    );

end component;

component baud_cnt is
    Port (
            clk         : in std_logic;                     -- Main clock. Rising edge 
            reset       : in std_logic;                     -- Main Reset
            cnt_limit   : in std_logic_vector(15 downto 0); -- Counter limit = frequency divider factor
                                                            -- 
            ck_en       : out std_logic                     -- Clock enable. Must be 3x faster than baud rate
    );
end component;

component RX is
    Port (  rx_in   : in std_logic;
            clk     : in std_logic; 
            ck_en   : in std_logic;
				 reset   : in std_logic;
            d_out   : out std_logic_vector(7 downto 0);
            full    : out std_logic;
            full_clr: in  std_logic
    );
end component;

component tx is
    Port (
           clk      : in std_logic;                     -- main clock
           ck_en    : in std_logic;                     -- clk enable. 3x faster than baud 
           reset    : in std_logic;                     -- main reset
           tx_out   : out std_logic;                    -- TX data
           d_in     : in std_logic_vector(7 downto 0);  -- byte tobe transmited
           load     : in std_logic;                     -- load signal for d_in 
           busy     : out std_logic                    -- '1' during transmission
    );
end component;
--------------------------------------
component muxk 
port(w0,w1,w2,w3: in std_logic_vector(255 downto 0);
		  f: out std_logic_vector(255 downto 0);
		  s: in std_logic_vector(1 downto 0)
		  );
end component;


component reg256 is
	port(R: in std_logic_vector(255 downto 0);
		  Q: out std_logic_vector(255 downto 0);
		  Rin,clk: in std_logic);
end component;

component reg251 is
	port(R: in std_logic_vector(250 downto 0);
		  Q: out std_logic_vector(250 downto 0);
		  En,clk: in std_logic);
end component;


end package;

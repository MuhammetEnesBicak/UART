library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity top is

    generic(
    clk_freq :  integer := 100_000_000;
    baud_rate : integer := 115_200;      
    stopbit :   integer := 2
    );
   
    port(
    start  : in std_logic;
    clk    : in std_logic;
    input  : in std_logic_vector(7 downto 0);
    output : out std_logic_vector(7 downto 0);
    parity_bit_tx : out std_logic;
    parity_bit_rx : out std_logic;
    done : out std_logic
    );
end top;


architecture Behavioral of top is

--------------------------
component Tx

generic(
    clk_freq :  integer := 100_000_000;
    baud_rate : integer := 115_200;      
    stopbit :   integer := 2
    );
   
port(
    clk : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    tx_start : in std_logic;
    tx_out : out std_logic;
    tx_done : out std_logic;
    parity_tx  : out std_logic
    );
 
end component;
---------------------------
component Rx

    generic(
    clk_freq :  integer := 100_000_000;
    baud_rate : integer := 115_200;      
    stopbit :   integer := 2
    );
   
    port(
    clk : in std_logic;
    received_bit : in std_logic;
    parity_in : in std_logic;
    received_byte : out std_logic_vector(7 downto 0);
    rx_done : out std_logic;
    parity_rx  : out std_logic
    );
---------------------------    
end  component;

signal s0 :  std_logic := '1';
signal s1,s2 : std_logic := '0';

begin

my_TX : Tx
 generic map(
    clk_freq  => 100_000_000,
    baud_rate => 115_200,      
    stopbit   => 2
    )
port map(
    clk => clk,
    data_in =>  input,
    tx_start => start,
    tx_out =>   s0,
    tx_done =>  s1,
    parity_tx  => s2
    );
---------------------------------
my_Rx : RX
generic map(
    clk_freq => 100_000_000,
    baud_rate => 115_200,    
    stopbit =>  2
    )
port map(
    clk               =>  clk,
    received_bit      => s0,
    parity_in         => s2,
    received_byte     => output,
    rx_done           => done,
    parity_rx        =>  parity_bit_rx
    );


parity_bit_tx <= s2;

end Behavioral;

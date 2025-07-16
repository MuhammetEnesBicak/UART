library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Tx is

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
 
end Tx;

architecture Behavioral of Tx is

type states is (IDLE_STATE,
                START_STATE,
                TRANSMIT_STATE,
                STOP_STATE);
               
constant bit_timer_lim : integer := clk_freq/baud_rate ;
constant stop_bit_lim  : integer := (clk_freq/baud_rate)*stopbit ;

signal bit_timer     : integer range 0 to stop_bit_lim := 0 ;
signal bit_counter   : integer range 0 to 7 := 0 ;
signal shift_reg     : std_logic_vector(7 downto 0) := (others => '0');
signal state : states := IDLE_STATE ;

begin


MAIN : process(clk)
begin

parity_tx <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor
                data_in(4) xor data_in(5) xor data_in(6) xor data_in(7);
if(rising_edge(clk)) then
   
    case state is
       -------------------------------------------------------
        when IDLE_STATE =>
       tx_out <= '1' ;
       tx_done <= '0';
       bit_counter <= 0 ;
       
          if(tx_start = '1') then
          state <= START_STATE ;
          tx_out <= '0' ;          --START BIT = 0
          shift_reg <= data_in ;   --LOAD DATA BYTE TO THE REGISTER
          end if;
      ---------------------------------------------------------  
       when START_STATE =>
       
      if(bit_timer = bit_timer_lim-1) then
               
            tx_out <= shift_reg(0);
            shift_reg <= shift_reg(0) & shift_reg(7 downto 1);
            state <= TRANSMIT_STATE;
            bit_timer <= 0;
      else
            bit_timer <= bit_timer+1;
     
      end if;
      ---------------------------------------------------------
         when  TRANSMIT_STATE =>
       
        if (bit_counter = 7) then
 
              if (bit_timer = bit_timer_lim-1) then
                  
                        bit_counter             <= 0;
                        state                   <= STOP_STATE;
                        tx_out                        <= '1';
                        bit_timer               <= 0;
              else
                        bit_timer               <= bit_timer + 1;                         
              end if;               
       
       
         else
         
                   if(bit_timer = bit_timer_lim-1) then
       
                       tx_out <= shift_reg(0);
                       shift_reg <= shift_reg(0) & shift_reg(7 downto 1);
                       bit_counter <= bit_counter+1;
                       bit_timer <= 0;
                   else
                       bit_timer <= bit_timer+1;
                   end if;
           
        end if;
       
       
      ---------------------------------------------------------  
        when STOP_STATE =>
       
        if(bit_timer = stop_bit_lim-1) then
       
            tx_done <= '1';
            state <= IDLE_STATE;
            bit_timer <= 0;
     
      else
            bit_timer <= bit_timer+1;
     
      end if;
      -------------------------------------------------------
end case;

end if;
end process;
end Behavioral;

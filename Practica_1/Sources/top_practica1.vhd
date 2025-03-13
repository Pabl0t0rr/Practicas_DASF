--------------------------------------------------------------------------------
--
-- Title       : 	Top module for practica 1
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : top_practica1.vhd
-- Generated   : 7 February 2022
--------------------------------------------------------------------------------
-- Description : Inputs and outputs for the practica 1
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 07/02/22  :| First version

-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_practica1 is
  generic (
      g_sys_clock_freq_KHZ  : integer := 100_000; -- Value of the clock frequencies in KHz
      g_debounce_time       : integer := 20;  -- Time for the debouncer in ms
      g_reset_value         : std_logic := '0'; -- Value for the synchronizer 
      g_number_flip_flps    : natural := 2   -- Number of flip-flops used to synchronize	
  );
  port (
      rst_n       : in std_logic; -- Negative reset must be connected to switch 0 
      clk100Mhz   : in std_logic; -- Connect to the main clk
      BTNC        : in std_logic; -- Connect to the button BTNC
      LED         : out std_logic -- Connect to the LED 0
  );
end top_practica1;

architecture behavioural of top_practica1 is
  -- Component declaration for debouncer
  component debouncer is
    generic(
        g_timeout         : integer  := 5; -- Time for debouncing (overridden value)
        g_clock_freq_KHZ  : integer  := 100_000 -- Frequency in KHz of the system (overridden value)
    );   
    port (  
        rst_n       : in    std_logic; -- Asynchronous reset, active-low
        clk         : in    std_logic; -- System clock
        ena         : in    std_logic; -- Enable must be 1 to work
        sig_in      : in    std_logic; -- Signal to debounce
        debounced   : out   std_logic  -- 1 pulse flag output when timeout has occurred
    ); 
  end component;

  -- Component declaration for synchronizer
  component synchronizer is
  generic (
    RESET_VALUE    : std_logic  := '0'; -- Reset value of all flip-flops in the chain
    NUM_FLIP_FLOPS : natural    := 2 -- Number of flip-flops in the synchronizer chain
  );
  port(
    rst      : in std_logic; -- Asynchronous, low-active
    clk      : in std_logic; -- Destination clock
    data_in  : in std_logic; -- Data that wants to be synchronized
    data_out : out std_logic -- Synchronized data
  );
  end component;

  -- Internal signals
  signal BTN_sync     : std_logic; -- Synchronized signal of BTNC 
  signal Toggle_LED   : std_logic; -- Internal signal between debouncer and toggle process
  signal LED_register : std_logic := '0'; -- Registered LED output
  signal state_LED    : std_logic; -- State of the LED toggle

begin
  -- DEBOUNCER INSTANCE
  debouncer_inst: debouncer
    generic map (
      g_timeout        => g_debounce_time, 
      g_clock_freq_KHZ => g_sys_clock_freq_KHZ
    )
    port map (
      rst_n     => rst_n,
      clk       => clk100Mhz,
      ena       => '1', -- Always enabled
      sig_in    => BTN_sync, -- Synchronized input
      debounced => Toggle_LED -- Output to toggle LED process
    );
  
  -- SYNCHRONIZER INSTANCE
  synchronizer_inst: synchronizer
    generic map (
      RESET_VALUE    => g_reset_value,
      NUM_FLIP_FLOPS => g_number_flip_flps
    )
    port map (
      rst      => rst_n,
      clk      => clk100Mhz,
      data_in  => BTNC,
      data_out => BTN_sync
    );
  
  -- PROCESS to register LED output 
  registerLED: process(clk100Mhz, rst_n)
  begin
    if (rst_n = '0') then
      LED_register <= '0'; -- Reset LED register when reset is active
    elsif rising_edge(clk100Mhz) then
      LED_register <= not LED_register; -- Update LED register state on clock rising edge
    end if;
  end process;  
  
  -- PROCESS to toggle LED
  toggleLED: process(Toggle_LED, LED_register)
  begin 
    if Toggle_LED = '1' then
      state_LED <= not LED_register; -- Toggle LED state when debounced signal is active
    else
      state_LED <= LED_register; -- Maintain current state otherwise
    end if;
  end process;

  -- Connect LED_register to the output LED
  LED <= LED_register;

end behavioural;

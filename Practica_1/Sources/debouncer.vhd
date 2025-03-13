library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic; -- asynchronous reset, low -active
        clk         : in    std_logic; -- system clk
        ena         : in    std_logic; -- enable must be on 1 to work (kind of synchronous reset)
        sig_in      : in    std_logic; -- signal to debounce
        debounced   : out   std_logic  -- 1 pulse flag output when the timeout has occurred
    ); 
end debouncer;


architecture Behavioural of debouncer is 
      
    -- Calculate the number of cycles of the counter (debounce_time * freq), result in cycles
    constant c_cycles           : integer := integer(g_timeout * g_clock_freq_KHZ) ;
    -- Calculate the length of the counter so the count fits
    constant c_counter_width    : integer := integer(ceil(log2(real(c_cycles))));
    
    -- ----------------------------------------------------------------------------- 
    -- Declarar un tipo para los estados de la fsm usando type 
    -- ----------------------------------------------------------------------------- 
    
    type state_type is (IDLE, BTN_PRS, VALID, BTN_UNPRS);
    signal state, next_state : state_type;
    signal time_elapsed : std_logic := '0';
    signal count : unsigned(c_counter_width-1 downto 0) := (others => '0');
    signal enable : STD_LOGIC := '0'; 
begin
    -- Timer
    process (clk, rst_n)
    begin
        if rst_n = '0' then
            count <= (others => '0');
            time_elapsed <= '0';
            if  ena = '1' then
                if count < c_cycles then
                count <= count + 1;
                time_elapsed <= '0';
                else
                count <= (others => '0');
                time_elapsed <= '1';
                end if;
             else
                count <= (others => '0'); 
                time_elapsed <= '0';    
            end if;
         end if;   
    end process;

    -- FSM Register of next state
    process (clk, rst_n)
    begin
        if rst_n = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
    
    process (state, ena, time_elapsed, sig_in)
    begin
        case state is
            when IDLE =>
                debounced <= '0';
                if sig_in = '1' then
                    next_state <= BTN_PRS;
                else
                    next_state <= IDLE;
                end if;
            when BTN_PRS =>
                debounced <= '0';
                if time_elapsed = '1' and sig_in = '1' then
                    count <= (others => '0'); 
                    next_state <= VALID;
                elsif time_elapsed = '1' and sig_in = '0' then
                    next_state <= IDLE; 
                elsif ena = '0' then
                    next_state <= IDLE;
                else
                    enable <= '1';
                    next_state <= BTN_PRS;
                end if;
            when VALID =>
                debounced <= '1';
                if sig_in = '0' then
                    next_state <= BTN_UNPRS;
                elsif ena = '0' then
                    next_state <= IDLE;
                else
                    next_state <= VALID;
                end if;
            when BTN_UNPRS =>
                debounced <= '0';
                if time_elapsed = '1' or ena = '0' then
                    count <= (others => '0');
                    next_state <= IDLE;
                else
                    enable <= '1';
                    next_state <= BTN_UNPRS;
                end if;
            when others =>
                next_state <= IDLE;
        end case;
    end process;
        
end Behavioural;

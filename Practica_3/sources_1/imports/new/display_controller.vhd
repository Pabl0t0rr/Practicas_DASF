----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2025 20:57:59
-- Design Name: 
-- Module Name: display_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity display_controller is
    Port ( 
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           count : in STD_LOGIC_VECTOR (7 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0)
    );
end display_controller;

architecture Behavioral of display_controller is
    signal digit_select : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal digit : STD_LOGIC_VECTOR(3 downto 0);
    signal refresh_counter : STD_LOGIC_VECTOR(19 downto 0);
    
    component seven_decoder
        Port ( 
               digit : in STD_LOGIC_VECTOR (3 downto 0);
               segments : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
begin
    -- Refresh counter for digit selection (1kHz)
    process(clk, reset)
    begin
        if reset = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;
    
    -- Use the most significant bits of refresh_counter to select the digit
    digit_select <= refresh_counter(19 downto 17);
    
    -- Select which digit is displayed
    process(digit_select, count)
    begin
        -- Default to all anodes inactive (high)
        an <= "11111111";
        
        case digit_select is
            when "000" =>  -- Rightmost digit
                an <= "11111110";
                digit <= count(3 downto 0);
            when "001" =>  -- Second digit from right
                an <= "11111101";
                digit <= count(7 downto 4);
            when others =>
                an <= "11111111";
                digit <= "0000";
        end case;
    end process;
    
    -- Instantiate seven-segment decoder
    U_DECODER: seven_decoder port map (
        digit => digit,
        segments => seg
    );
end Behavioral;

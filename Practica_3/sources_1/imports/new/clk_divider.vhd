----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2025 20:22:14
-- Design Name: 
-- Module Name: clk_divider - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_divider is
    Generic ( SIMULATION_MODE : boolean := false );
    Port ( clk_in : in STD_LOGIC;
           reset : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end clk_divider;

architecture Behavioral of clk_divider is
    -- 100MHz a 1Hz: 100.000.000 / 2 = 50.000.000 

    -- constant DIVIDER_VALUE : integer := 5 when SIMULATION_MODE else 50000000;
    constant DIVIDER_VALUE : integer := 50000000;
    signal counter : integer range 0 to 50000000 := 0;
    signal temp_clk : STD_LOGIC := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= 0;
            temp_clk <= '0';
        elsif rising_edge(clk_in) then
            if counter = DIVIDER_VALUE-1 then
                counter <= 0;
                temp_clk <= not temp_clk;  -- Toggle clock
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    clk_out <= temp_clk;
end Behavioral;

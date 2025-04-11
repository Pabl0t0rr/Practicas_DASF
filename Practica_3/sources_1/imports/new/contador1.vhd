----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.03.2025 18:31:53
-- Design Name: 
-- Module Name: contador1 - Behavioral
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

entity contador1 is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           count : out STD_LOGIC_VECTOR (7 downto 0));
end contador1;

architecture Behavioral of contador1 is
    signal temp_count : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' or enable = '0' then
            temp_count <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                temp_count <= temp_count + 1;
            end if;
        end if;
    end process;
    count <= temp_count;
end Behavioral;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor_3 is
    port(
        clk         : in  std_logic;
        ena         : in  std_logic;  -- reset asíncrono (activo en '0')
        f_div_2_5   : out std_logic;  -- salida de 2.5MHz (100MHz/40)
        f_div_1_25  : out std_logic;  -- salida de 1.25MHz (100MHz/80)
        f_div_500   : out std_logic   -- salida de 500KHz (100MHz/200)
    );
end entity divisor_3;

architecture Behavioral of divisor_3 is
     -- Contador de módulo 40
     signal count40 : unsigned(5 downto 0) := (others => '0'); -- f_div_2_5
     -- Contador de módulo 2 (para dividir la señal de 2.5MHz a 1.25MHz)
     signal count2 : unsigned(0 downto 0) := (others => '0');-- f_div_1_25
     -- Contador de módulo 5 (para dividir la señal de 2.5MHz a 500KHz)
     signal count5 : unsigned(2 downto 0) := (others => '0'); --f_div_500

     signal e_pulse_div40 : std_logic := '0';  -- pulso de 1 ciclo a 2.5MHz, cada vez que el contador de módulo 40 se resetea

begin
     -- Proceso del contador de módulo 40
     process(clk, ena)
        begin
            if ena = '0' then
                count40 <= (others => '0');
            elsif rising_edge(clk) then
                if count40 = 39 then
                    count40 <= (others => '0');
                else
                    count40 <= count40 + 1;
                end if;
            end if;   
     end process;

     -- Genera un pulso (de 1 ciclo del reloj de 100MHz) cuando count40 = 0
     e_pulse_div40 <= '1' when count40 = 0 else '0';

     -- Proceso para el contador de módulo 2 (para obtener 1,25 MHz)
     process(clk, ena)
          begin
              if ena = '0' then
                   count2 <= (others => '0');
              elsif rising_edge(clk) then
                if e_pulse_div40 = '1' then
                      if count2 = 1 then
                           count2 <= (others => '0');
                      else
                           count2 <= count2 + 1;
                      end if;
                 
                 end if; 
              end if;
    end process;

      -- Proceso para el contador de módulo 5 (para obtener 500 KHz)
    process(clk, ena)
     begin
        if ena = '0' then
            count5 <= (others => '0');
        elsif rising_edge(clk) then
            if e_pulse_div40 = '1' then
                if count5 = 4 then
                    count5 <= (others => '0');
                else
                    count5 <= count5 + 1;
                end if;
            end if;
        end if;
     end process;

     -- Asignaciones de salida: cada señal es un pulso de 1 ciclo de reloj
    f_div_2_5  <= e_pulse_div40;
    f_div_1_25 <= '1' when (e_pulse_div40 = '1' and count2 = "0") else '0';
    f_div_500  <= '1' when (e_pulse_div40 = '1' and count5 = "0") else '0';
    
end Behavioral;


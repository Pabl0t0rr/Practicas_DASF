library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_divisor_3 is
end entity tb_divisor_3;

architecture Behavioral of tb_divisor_3 is
   component divisor_3 is
      port(
          clk         : in  std_logic;
          ena         : in  std_logic;
          f_div_2_5   : out std_logic;
          f_div_1_25  : out std_logic;
          f_div_500   : out std_logic
      );
   end component;

   signal clk        : std_logic := '0';
   signal ena        : std_logic := '0';
   signal f_div_2_5  : std_logic;
   signal f_div_1_25 : std_logic;
   signal f_div_500  : std_logic;
   
   constant clk_period : time := 10 ns;  -- Período de 100MHz
begin
   uut: divisor_3 port map (
       clk        => clk,
       ena        => ena ,
       f_div_2_5  => f_div_2_5,
       f_div_1_25 => f_div_1_25,
       f_div_500  => f_div_500
   );

   -- Generador de reloj
   clk_process : process
   begin
      while true loop
         clk <= '0';
         wait for clk_period/2;
         clk <= '1';
         wait for clk_period/2;
      end loop;
   end process;

   -- Estímulos
   stimulus: process
   begin
      -- Aplicar reset
      ena  <= '0';
      wait for 40 ns;
      ena  <= '1';
      wait for 500 ns;
      ena  <= '0';
      wait for 40 ns;
      ena  <= '1';
      
      -- Ejecutar la simulación durante 20000 ns para observar las salidas
      wait for 20000 ns;
      
      assert false report "Simulación terminada" severity failure;
   end process;
end Behavioral;

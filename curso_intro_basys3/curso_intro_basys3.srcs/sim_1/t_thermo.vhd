-- el nombre empieza con t_ para indicar que es un test

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- la entidad la dejamos vacia
entity T_THERMO is
end T_THERMO;

-- esto lo copiamos cambiando entity por component
architecture TEST of T_THERMO is
component THERMO
port (
        CURRENT_TEMP :    in bit_vector(6 downto 0);
        DESIRED_TEMP :    in bit_vector(6 downto 0);
        DISPLAY_SELECT :  in bit;
        COLD :            in bit;
        HEAT :            in bit;
        AC_ON :          out bit;
        FURNACE_ON :      out bit;
        TEMP_DISPLAY :    out bit_vector(6 downto 0)
        );
        
end component;
-- senales internas, en este caso les damos el mismo nombre
signal CURRENT_TEMP, DESIRED_TEMP : bit_vector( 6 downto 0);
signal DISPLAY_SELECT, COLD, HEAT : bit;
signal TEMP_DISPLAY : bit_vector( 6 downto 0);
signal AC_ON, FURNACE_ON : bit;

begin
-- cremos component under test, y conectarmos las senales externas a las internas (con el mismo nombre)
UUT: THERMO port map(  CURRENT_TEMP => CURRENT_TEMP,
                        DESIRED_TEMP => DESIRED_TEMP,
                        DISPLAY_SELECT => DISPLAY_SELECT,
                        COLD => COLD,
                        HEAT => HEAT,
                        AC_ON => AC_ON,
                        FURNACE_ON => FURNACE_ON,
                        TEMP_DISPLAY => TEMP_DISPLAY
                        );
process
-- aqui no hay sensitivity list, lo que hace que siempre entre y se cree un bucle infinito
begin
CURRENT_TEMP <= "0001111";
DESIRED_TEMP <= "1111111";
DISPLAY_SELECT <= '0';
COLD <= '0';
HEAT <= '0';
wait for 10 ns;
DISPLAY_SELECT <= '1';
HEAT <= '1';
wait for 10 ns;
DESIRED_TEMP <= "0000000";
wait for 10 ns;
HEAT <= '0';
COLD <= '1';
wait;  -- aqui hace una parada
end process;
end TEST;
-- el nombre empieza con t_ para indicar que es un test

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- entity remains empty
entity T_THERMO is
end T_THERMO;

-- copy/paste from entity, changing "entity" for "component"
architecture TEST of T_THERMO is
component THERMO
port (
    CLK:              in bit; 
    RESET:            in bit; 
    CURRENT_TEMP :    in bit_vector(6 downto 0);
    DESIRED_TEMP :    in bit_vector(6 downto 0);
    DISPLAY_SELECT :  in bit;
    COOL :            in bit;
    HEAT :            in bit;
    AC_ON :           out bit;
    FURNACE_ON :      out bit;
    TEMP_DISPLAY :    out bit_vector(6 downto 0)
    );
end component;
-- internal signals with the same name
signal CURRENT_TEMP, DESIRED_TEMP : bit_vector( 6 downto 0);
signal CLK, RESET, DISPLAY_SELECT, COOL, HEAT : bit;
signal TEMP_DISPLAY : bit_vector( 6 downto 0);
signal AC_ON, FURNACE_ON : bit;

begin
-- component under test, connect internal with external signals (same names)
UUT: THERMO port map(  
    CLK => CLK,
    RESET => RESET,
    CURRENT_TEMP => CURRENT_TEMP,
    DESIRED_TEMP => DESIRED_TEMP,
    DISPLAY_SELECT => DISPLAY_SELECT,
    COOL => COOL,
    HEAT => HEAT,
    AC_ON => AC_ON,
    FURNACE_ON => FURNACE_ON,
    TEMP_DISPLAY => TEMP_DISPLAY
    );

process
    -- without selsivility list, it always enters and creates an infinite loop
begin
    CLK <= '0';
    RESET <= '0';
    CURRENT_TEMP <= "0001111";
    DESIRED_TEMP <= "1111111";
    DISPLAY_SELECT <= '0';
    COOL <= '0';
    HEAT <= '0';
    wait for 10 ns;
    DISPLAY_SELECT <= '1';
    HEAT <= '1';
    wait for 10 ns;
    DESIRED_TEMP <= "0000000";
    wait for 10 ns;
    HEAT <= '0';
    COOL <= '1';
    wait;
end process;
end TEST;
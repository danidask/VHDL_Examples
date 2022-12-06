-- test filenames start with t_ 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- entity remains empty
entity T_THERMO is
end T_THERMO;

-- copy/paste from entity, changing "entity" for "component"
architecture TEST of T_THERMO is
component THERMO
  port (
    CLK:              in std_logic;
    NRESET:           in std_logic;
    CURRENT_TEMP :    in std_logic_vector(6 downto 0);
    DESIRED_TEMP :    in std_logic_vector(6 downto 0);
    DISPLAY_SELECT :  in std_logic;
    COOL :            in std_logic;
    HEAT :            in std_logic;
    FURNACE_HOT :     in std_logic;
    AC_READY :        in std_logic;
    AC_ON :           out std_logic;
    FURNACE_ON :      out std_logic;
    FAN_ON :          out std_logic;
    TEMP_DISPLAY :    out std_logic_vector(6 downto 0)
  );
end component;
-- internal signals with the same name
signal CURRENT_TEMP, DESIRED_TEMP : std_logic_vector( 6 downto 0);
signal NRESET, DISPLAY_SELECT, COOL, HEAT, FURNACE_HOT, AC_READY : std_logic;
signal CLK : std_logic := '0';
signal TEMP_DISPLAY : std_logic_vector( 6 downto 0);
signal AC_ON, FURNACE_ON, FAN_ON : std_logic;

begin

-- component under test, connect internal with external signals (same names)
UUT: THERMO port map(  
    CLK => CLK,
    NRESET => NRESET,
    CURRENT_TEMP => CURRENT_TEMP,
    DESIRED_TEMP => DESIRED_TEMP,
    DISPLAY_SELECT => DISPLAY_SELECT,
    COOL => COOL,
    HEAT => HEAT,
    FURNACE_HOT => FURNACE_HOT,
    AC_READY => AC_READY,
    AC_ON => AC_ON,
    FURNACE_ON => FURNACE_ON,
    FAN_ON => FAN_ON,
    TEMP_DISPLAY => TEMP_DISPLAY
    );

-- generate clock (concurrent statement, outside process)
CLK <= not CLK after 3 ns;

process
    -- without selsivility list, it always enters and creates an infinite loop
  begin
    NRESET <= '1';
    CURRENT_TEMP <= "0000111";
    DESIRED_TEMP <= "0001111";
    DISPLAY_SELECT <= '0';
    COOL <= '0';
    HEAT <= '0';
    FURNACE_HOT <= '0';
    AC_READY <= '0';
    wait for 100 ns;
    DISPLAY_SELECT <= '1';
    HEAT <= '1';
    wait for 100 ns;
    FURNACE_HOT <= '1';
    wait for 100 ns;
    HEAT <= '0';
    wait for 100 ns;
    FURNACE_HOT <= '0';
    COOL <= '1';
    wait for 100 ns;
    DESIRED_TEMP <= "0000001";
    wait for 100 ns;
    AC_READY <= '1';
    wait for 100 ns;
    COOL <= '0';
    wait for 100 ns;
    AC_READY <= '0';
    wait for 100 ns;    
    wait;
  end process;
end TEST;
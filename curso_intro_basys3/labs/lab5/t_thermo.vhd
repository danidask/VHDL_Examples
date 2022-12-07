-- test filenames start with t_ 

library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;

-- entity remains empty
entity T_THERMO is
end T_THERMO;

-- copy/paste from entity, changing "entity" for "component"
architecture TEST of T_THERMO is
component THERMO
  port (
    clk:                in std_logic;
    nreset:             in std_logic;
    i_current_temp :    in std_logic_vector(6 downto 0);
    i_desired_temp :    in std_logic_vector(6 downto 0);
    i_display_select :  in std_logic;
    i_cool :            in std_logic;
    i_heat :            in std_logic;
    i_furnace_hot :     in std_logic;
    i_ac_ready :        in std_logic;
    o_ac_on :           out std_logic;
    o_furnace_on :      out std_logic;
    o_fan_on :          out std_logic;
    o_temp_display :    out std_logic_vector(6 downto 0)
  );
end component;
-- internal signals with the same name
signal clk : std_logic := '0';
signal i_current_temp, i_desired_temp : std_logic_vector( 6 downto 0);
signal nreset, i_display_select, i_cool, i_heat, i_furnace_hot, i_ac_ready : std_logic;
signal o_temp_display : std_logic_vector( 6 downto 0);
signal o_ac_on, o_furnace_on, o_fan_on : std_logic;
constant DELAY_TIME : time := 50 ns;


begin

-- component under test, connect internal with external signals (same names)
UUT: THERMO port map(  
    clk => clk,
    nreset => nreset,
    i_current_temp => i_current_temp,
    i_desired_temp => i_desired_temp,
    i_display_select => i_display_select,
    i_cool => i_cool,
    i_heat => i_heat,
    i_furnace_hot => i_furnace_hot,
    i_ac_ready => i_ac_ready,
    o_ac_on => o_ac_on,
    o_furnace_on => o_furnace_on,
    o_fan_on => o_fan_on,
    o_temp_display => o_temp_display
    );

-- generate clock (concurrent statement, outside process)
clk <= not clk after 3 ns;

process
    -- without selsivility list, it always enters and creates an infinite loop
  begin
    nreset <= '1';
    i_current_temp <= "0000111";
    i_desired_temp <= "0001111";
    i_display_select <= '0';
    i_cool <= '0';
    i_heat <= '0';
    i_furnace_hot <= '0';
    i_ac_ready <= '0';
    wait for DELAY_TIME;
    i_display_select <= '1';
    i_heat <= '1';
    wait for DELAY_TIME;
    i_furnace_hot <= '1';
    wait for DELAY_TIME;
    i_heat <= '0';
    wait for DELAY_TIME*3;
    i_furnace_hot <= '0';
    wait for DELAY_TIME*3;
    i_cool <= '1';
    wait for DELAY_TIME;
    i_desired_temp <= "0000001";
    wait for DELAY_TIME;
    i_ac_ready <= '1';
    wait for DELAY_TIME;
    i_cool <= '0';
    wait for DELAY_TIME;
    i_ac_ready <= '0';
    wait for 100 ns;    
    wait;
  end process;
end TEST;
-- test filenames start with t_ 

library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;  -- conv_std_logic_vector

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

constant PERIOD : time := 10 ns;
constant DELAY_TIME : time := 53 ns;

function int_to_dstring(int_val, int_no : integer) return string is
  variable temp_string : string(int_no downto 1);
  variable temp_int, temp_dig : integer;
  begin
    temp_int := int_val;
    for i in 1 to int_no loop
      temp_dig := temp_int - ((temp_int / 10) * 10);
      temp_int := temp_int / 10;
      case temp_dig is
        when 0 => temp_string(i) := '0';
        when 1 => temp_string(i) := '1';
        when 2 => temp_string(i) := '2';
        when 3 => temp_string(i) := '3';
        when 4 => temp_string(i) := '4';
        when 5 => temp_string(i) := '5';
        when 6 => temp_string(i) := '6';
        when 7 => temp_string(i) := '7';
        when 8 => temp_string(i) := '8';
        when 9 => temp_string(i) := '9';
        when others => temp_string(i) := 'X';
      end case;
    end loop;
    return temp_string;
end function;

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
clk <= not clk after PERIOD / 2;

-- other concurrent stimulus
-- i_display_select <= '0', 
--                     '1' after DELAY_TIME*3,
--                     '0' after DELAY_TIME*7;  -- from initial value, not previous

process
  variable furnace_off_time, fan_off_time, time_span : time;
begin
  wait until o_furnace_on'event and o_furnace_on = '0';
  furnace_off_time := now;
  wait until o_fan_on'event and o_fan_on = '0';
  fan_off_time := now;
  time_span := fan_off_time - furnace_off_time;
  assert false report "o_furnace_on time: " & time'image(time_span) severity note;
end process;

-- timeout
-- process
-- begin
--   wait until clk'event and clk = '1';
--   assert now > PERIOD*500 report "timeout" severity failure;
-- end process;

  process  -- without selsivility list, it always enters and creates an infinite loop
  procedure set_current_temp (temp : integer) is
  begin
    i_current_temp <= conv_std_logic_vector(temp, i_current_temp'length);
  end procedure;

  procedure set_both_temps (current, desired: in integer) is
  begin
    set_current_temp(current);
    i_desired_temp <= conv_std_logic_vector(desired, i_desired_temp'length);
  end procedure;

  begin
    nreset <= '1';
    set_current_temp(6);
    i_desired_temp <= std_logic_vector(to_unsigned(16#0A#, i_desired_temp'length));
    i_cool <= '0';
    i_heat <= '0';
    i_furnace_hot <= '0';
    i_ac_ready <= '0';
    i_display_select <= '0';
    assert FALSE report "Test started" severity note;
    wait for DELAY_TIME;
    -- test display
    set_both_temps(current => 10, desired =>20);
    i_display_select <= '1';
    wait for DELAY_TIME;
    assert o_temp_display = conv_std_logic_vector(11, o_temp_display'length) 
      report "Temperature display error. o_temp_display should be 10 and is " & int_to_dstring(10, 2) severity error;
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
    set_both_temps(current => 10, desired =>16#05#);
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
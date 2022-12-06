library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
-- type UNSIGNED is array (NATURAL range <>) of STD_LOGIC;
-- type SIGNED is array (NATURAL range <>) of STD_LOGIC;


entity THERMO is
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
end THERMO;

architecture RTL of THERMO is
  -- signals for internal registers (flip-flops)
  signal i_current_temp_reg, i_desired_temp_reg, o_temp_display_reg : std_logic_vector(6 downto 0) := "0000000";
  signal i_display_select_reg, i_cool_reg, i_heat_reg, o_ac_on_reg, o_furnace_on_reg, o_fan_on_reg, i_furnace_hot_reg, i_ac_ready_reg : std_logic := '0';

  type FSM_STATES is (IDLE_STATE, HEAT_ON_STATE, FURNACE_NOW_HOT_STATE, FURNACE_COOL_STATE, COOL_ON_STATE, AC_NOW_READY_STATE, AC_DONE_STATE);
  signal state, next_state : FSM_STATES := IDLE_STATE;

  -- All processes sensitive only to clk and nreset, and will be trigguered in each rising edge or when reset is asserted
begin
  -- Register all inputs into flip-flops
  process (clk, nreset)
  begin
    if nreset = '0' then
      -- default values
      i_current_temp_reg <= "0000000";
      i_desired_temp_reg <= "0000000";
      i_display_select_reg <= '0';
      i_cool_reg <= '0';
      i_heat_reg <= '0';
      i_furnace_hot_reg <= '0';
      i_ac_ready_reg <= '0';
    elsif clk'event and clk = '1' then
      i_current_temp_reg <= i_current_temp;
      i_desired_temp_reg <= i_desired_temp;
      i_display_select_reg <= i_display_select;
      i_cool_reg <= i_cool;
      i_heat_reg <= i_heat;
      i_furnace_hot_reg <= i_furnace_hot;
      i_ac_ready_reg <= i_ac_ready;
    end if;
  end process;

  -- update the outputs with the registered values
  process (clk, nreset)
  begin
    if nreset = '0' then
      o_ac_on <= '0';
      o_furnace_on <= '0';
      o_fan_on <= '0';
      o_temp_display <= "0000000";
    elsif clk'event and clk = '1' then
      o_ac_on <= o_ac_on_reg;
      o_furnace_on <= o_furnace_on_reg;
      o_temp_display <= o_temp_display_reg;
      o_fan_on <= o_fan_on_reg;
    end if;
  end process;

  -- update the display register
  process (clk)
  begin
    if clk'event and clk = '1' then
      if i_display_select_reg = '1' then
        o_temp_display_reg <= i_current_temp_reg;
      else
        o_temp_display_reg <= i_desired_temp_reg;
      end if;
    end if;
  end process;

  -- State machine
  process (state, i_current_temp_reg, i_desired_temp_reg, i_cool_reg, i_heat_reg, i_furnace_hot_reg, i_ac_ready_reg)
  begin
    case state is
      when IDLE_STATE =>
        o_furnace_on_reg <= '0';
        o_ac_on_reg <= '0';
        o_fan_on_reg <= '0';
        if i_heat_reg = '1' and i_current_temp_reg < i_desired_temp_reg then
          next_state <= HEAT_ON_STATE;
        elsif i_cool_reg = '1' and i_current_temp_reg > i_desired_temp_reg then
          next_state <= COOL_ON_STATE;
        else
          next_state <= IDLE_STATE;
        end if;
      when HEAT_ON_STATE =>
        o_furnace_on_reg <= '1';
        o_ac_on_reg <= '0';
        o_fan_on_reg <= '0';
        if i_furnace_hot_reg = '1' then
          next_state <= FURNACE_NOW_HOT_STATE;
        else
          next_state <= HEAT_ON_STATE;
        end if;
      when FURNACE_NOW_HOT_STATE =>
        o_furnace_on_reg <= '1';
        o_ac_on_reg <= '0';
        o_fan_on_reg <= '1';
        if not (i_heat_reg = '1' and i_current_temp_reg < i_desired_temp_reg) then
          next_state <= FURNACE_COOL_STATE;
        else
          next_state <= FURNACE_NOW_HOT_STATE;
        end if;
      when FURNACE_COOL_STATE =>
        o_furnace_on_reg <= '0';
        o_ac_on_reg <= '0';
        o_fan_on_reg <= '1';
        if i_furnace_hot_reg = '0' then
          next_state <= IDLE_STATE;
        else
          next_state <= FURNACE_COOL_STATE;
        end if;
      when COOL_ON_STATE =>
        o_furnace_on_reg <= '0';
        o_ac_on_reg <= '1';
        o_fan_on_reg <= '0';
        if i_ac_ready_reg = '1' then
          next_state <= AC_NOW_READY_STATE;
        else
          next_state <= COOL_ON_STATE;
        end if;
      when AC_NOW_READY_STATE =>
        o_furnace_on_reg <= '0';
        o_ac_on_reg <= '1';
        o_fan_on_reg <= '1';
        if not (i_cool_reg = '1' and i_current_temp_reg > i_desired_temp_reg) then
          next_state <= FURNACE_COOL_STATE;
        else
          next_state <= AC_NOW_READY_STATE;
        end if;
      when AC_DONE_STATE =>
        o_furnace_on_reg <= '0';
        o_ac_on_reg <= '0';
        o_fan_on_reg <= '1';
        if i_ac_ready_reg = '0' then
          next_state <= IDLE_STATE;
        else
          next_state <= AC_DONE_STATE;
        end if;        
      when others =>
        next_state <= IDLE_STATE;
    end case;
  end process;

  process (clk, nreset)
  begin
    if nreset = '0' then
      state <= IDLE_STATE;
    elsif clk'event and clk = '1' then
      state <= next_state;
    end if;
  end process;

end RTL;
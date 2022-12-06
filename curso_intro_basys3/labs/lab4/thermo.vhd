library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Lab4
-- We will add a state machine to our thermostat design to control when the heat and A/C are on, and when the fan is used for each mode.
-- change bit and bit_vector to std_logic and std_logic_vector
-- outputs should be a function of state or next_state
entity THERMO is
  port (
    CLK : in std_logic;
    NRESET : in std_logic;
    CURRENT_TEMP : in std_logic_vector(6 downto 0);
    DESIRED_TEMP : in std_logic_vector(6 downto 0);
    DISPLAY_SELECT : in std_logic;
    COOL : in std_logic;
    HEAT : in std_logic;
    FURNACE_HOT : in std_logic;
    AC_READY : in std_logic;
    AC_ON : out std_logic;
    FURNACE_ON : out std_logic;
    FAN_ON : out std_logic;
    TEMP_DISPLAY : out std_logic_vector(6 downto 0)
  );
end THERMO;

architecture RTL of THERMO is
  -- signals for internal registers (flip-flops)
  signal CURRENT_TEMP_REG, DESIRED_TEMP_REG, TEMP_DISPLAY_REG : std_logic_vector(6 downto 0) := "0000000";
  signal DISPLAY_SELECT_REG, COOL_REG, HEAT_REG, AC_ON_REG, FURNACE_ON_REG, FAN_ON_REG, FURNACE_HOT_REG, AC_READY_REG : std_logic := '0';

  type FSM_STATES is (IDLE_STATE, HEAT_ON_STATE, FURNACE_NOW_HOT_STATE, FURNACE_COOL_STATE, COOL_ON_STATE, AC_NOW_READY_STATE, AC_DONE_STATE);
  signal state, next_state : FSM_STATES := IDLE_STATE;

  -- All processes sensitive only to CLK and NRESET, and will be trigguered in each rising edge or when reset is asserted
begin
  -- Register all inputs into flip-flops
  process (CLK, NRESET)
  begin
    if NRESET = '0' then
      -- default values
      CURRENT_TEMP_REG <= "0000000";
      DESIRED_TEMP_REG <= "0000000";
      DISPLAY_SELECT_REG <= '0';
      COOL_REG <= '0';
      HEAT_REG <= '0';
      FURNACE_HOT_REG <= '0';
      AC_READY_REG <= '0';
    elsif CLK'event and CLK = '1' then
      CURRENT_TEMP_REG <= CURRENT_TEMP;
      DESIRED_TEMP_REG <= DESIRED_TEMP;
      DISPLAY_SELECT_REG <= DISPLAY_SELECT;
      COOL_REG <= COOL;
      HEAT_REG <= HEAT;
      FURNACE_HOT_REG <= FURNACE_HOT;
      AC_READY_REG <= AC_READY;
    end if;
  end process;

  -- update the outputs with the registered values
  process (CLK, NRESET)
  begin
    if NRESET = '0' then
      AC_ON <= '0';
      FURNACE_ON <= '0';
      FAN_ON <= '0';
      TEMP_DISPLAY <= "0000000";
    elsif CLK'event and CLK = '1' then
      AC_ON <= AC_ON_REG;
      FURNACE_ON <= FURNACE_ON_REG;
      TEMP_DISPLAY <= TEMP_DISPLAY_REG;
      FAN_ON <= FAN_ON_REG;
    end if;
  end process;

  -- update the display register
  process (CLK)
  begin
    if CLK'event and CLK = '1' then
      if DISPLAY_SELECT_REG = '1' then
        TEMP_DISPLAY_REG <= CURRENT_TEMP_REG;
      else
        TEMP_DISPLAY_REG <= DESIRED_TEMP_REG;
      end if;
    end if;
  end process;

  -- State machine
  process (state, CURRENT_TEMP_REG, DESIRED_TEMP_REG, COOL_REG, HEAT_REG, FURNACE_HOT_REG, AC_READY_REG)
  begin
    case state is
      when IDLE_STATE =>
        FURNACE_ON_REG <= '0';
        AC_ON_REG <= '0';
        FAN_ON_REG <= '0';
        if HEAT_REG = '1' and CURRENT_TEMP_REG < DESIRED_TEMP_REG then
          next_state <= HEAT_ON_STATE;
        elsif COOL_REG = '1' and CURRENT_TEMP_REG > DESIRED_TEMP_REG then
          next_state <= COOL_ON_STATE;
        else
          next_state <= IDLE_STATE;
        end if;
      when HEAT_ON_STATE =>
        FURNACE_ON_REG <= '1';
        AC_ON_REG <= '0';
        FAN_ON_REG <= '0';
        if FURNACE_HOT_REG = '1' then
          next_state <= FURNACE_NOW_HOT_STATE;
        else
          next_state <= HEAT_ON_STATE;
        end if;
      when FURNACE_NOW_HOT_STATE =>
        FURNACE_ON_REG <= '1';
        AC_ON_REG <= '0';
        FAN_ON_REG <= '1';
        if not (HEAT_REG = '1' and CURRENT_TEMP_REG < DESIRED_TEMP_REG) then
          next_state <= FURNACE_COOL_STATE;
        else
          next_state <= FURNACE_NOW_HOT_STATE;
        end if;
      when FURNACE_COOL_STATE =>
        FURNACE_ON_REG <= '0';
        AC_ON_REG <= '0';
        FAN_ON_REG <= '1';
        if FURNACE_HOT_REG = '0' then
          next_state <= IDLE_STATE;
        else
          next_state <= FURNACE_COOL_STATE;
        end if;
      when COOL_ON_STATE =>
        FURNACE_ON_REG <= '0';
        AC_ON_REG <= '1';
        FAN_ON_REG <= '0';
        if AC_READY_REG = '1' then
          next_state <= AC_NOW_READY_STATE;
        else
          next_state <= COOL_ON_STATE;
        end if;
      when AC_NOW_READY_STATE =>
        FURNACE_ON_REG <= '0';
        AC_ON_REG <= '1';
        FAN_ON_REG <= '1';
        if not (COOL_REG = '1' and CURRENT_TEMP_REG > DESIRED_TEMP_REG) then
          next_state <= FURNACE_COOL_STATE;
        else
          next_state <= AC_NOW_READY_STATE;
        end if;
      when AC_DONE_STATE =>
        FURNACE_ON_REG <= '0';
        AC_ON_REG <= '0';
        FAN_ON_REG <= '1';
        if AC_READY_REG = '0' then
          next_state <= IDLE_STATE;
        else
          next_state <= AC_DONE_STATE;
        end if;        
      when others =>
        next_state <= IDLE_STATE;
    end case;
  end process;

  process (CLK, NRESET)
  begin
    if NRESET = '0' then
      state <= IDLE_STATE;
    elsif CLK'event and CLK = '1' then
      state <= next_state;
    end if;
  end process;

end RTL;
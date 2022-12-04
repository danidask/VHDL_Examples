library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- the goal is to register all inputs an outputs (see pic) and update signals at clock edge
-- 1) Start with a copy of the previous lab.
-- 2) Add registers to the inputs.
-- 3) Create internal signals for the registered input values.
-- 4) Register the outputs.  You can either put the combinatorial logic in a clocked process, or keep the combinatorial process for the logic and add a clocked process for registering the outputs.
-- 5) Generate a clock in the test bench.    If needed, generate a reset in the test bench.
-- 6) Simulate your design and verify the flip-flops are behaving correctly.


entity THERMO is
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
  end THERMO;
  
  architecture RTL of THERMO is
  -- signals for internal registers (flip-flops)
  signal CURRENT_TEMP_REG, DESIRED_TEMP_REG, TEMP_DISPLAY_REG: bit_vector(6 downto 0);
  signal DISPLAY_SELECT_REG, COOL_REG, HEAT_REG, AC_ON_REG, FURNACE_ON_REG: bit;

  -- All processes sensitive only to CLK and RESET, and will be trigguered in each rising edge or when assert RESET
  begin
    -- Register all inputs into flip-flops
    process (CLK, RESET)
    begin
      if RESET = '1' then
        -- default values
        CURRENT_TEMP_REG <= "0000000";
        DESIRED_TEMP_REG <= "0000000";
        DISPLAY_SELECT_REG <= '0';
        COOL_REG <= '0';
        HEAT_REG <= '0';
      elsif CLK'event and CLK = '1' then
        CURRENT_TEMP_REG <= CURRENT_TEMP;
        DESIRED_TEMP_REG <= DESIRED_TEMP;
        DISPLAY_SELECT_REG <= DISPLAY_SELECT;
        COOL_REG <= COOL;
        HEAT_REG <= HEAT;
      end if;      
    end process;

    -- update the outputs with the registered values
    process (CLK, RESET)
    begin
      if RESET = '1' then
        AC_ON <= '0';
        FURNACE_ON <= '0';
        TEMP_DISPLAY <= "0000000";
      elsif CLK'event and CLK = '1' then
        AC_ON <= AC_ON_REG;
        FURNACE_ON <= FURNACE_ON_REG;
        TEMP_DISPLAY <= TEMP_DISPLAY_REG;
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
    
    -- furnace/AC logic (trough registers)
    process (CLK)
    begin
      if CLK'event and CLK = '1' then
        if HEAT_REG = '1' and CURRENT_TEMP_REG < DESIRED_TEMP_REG then
          FURNACE_ON_REG <= '1';
        else
          FURNACE_ON_REG <= '0';
        end if;        
        if COOL_REG = '1' and CURRENT_TEMP_REG > DESIRED_TEMP_REG then
          AC_ON_REG <= '1';
        else
          AC_ON_REG <= '0';          
        end if;        
      end if;      
    end process;    
  
  end RTL;
  
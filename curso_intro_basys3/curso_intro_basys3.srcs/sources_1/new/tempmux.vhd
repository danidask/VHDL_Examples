library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TEMPMUX is
    port (
      CURRENT_TEMP :    in bit_vector(6 downto 0);
      DESIRED_TEMP :    in bit_vector(6 downto 0);
      DISPLAY_SELECT :  in bit;
      COLD :            in bit;
      HEAT :            in bit;
      A_C_ON :          out bit;
      FURNACE_ON :      out bit;
      TEMP_DISPLAY :    out bit_vector(6 downto 0)
    );
  end TEMPMUX;
  
  architecture Behavioral of TEMPMUX is
  begin
    process (DISPLAY_SELECT, CURRENT_TEMP, DESIRED_TEMP, COLD, HEAT)
    begin
      if DISPLAY_SELECT = '1' then
        TEMP_DISPLAY <= CURRENT_TEMP;
      else
        TEMP_DISPLAY <= DESIRED_TEMP;
      end if;
      A_C_ON <= '0';  -- default state if no conditions are met
      FURNACE_ON <= '0';
      if HEAT = '1' and CURRENT_TEMP < DESIRED_TEMP then
        FURNACE_ON <= '1';
      elsif COLD = '1' and CURRENT_TEMP > DESIRED_TEMP then
        A_C_ON <= '1';
      end if;
    end process;
  
  end Behavioral;
  
entity TEMPMUX is
  port (
    CURRENT_TEMP :    in bit_vector(6 downto 0);
    DESIRED_TEMP :    in bit_vector(6 downto 0);
    DISPLAY_SELECT :  in bit;
    TEMP_DISPLAY :    out bit_vector(6 downto 0)
  );
end TEMPMUX;

architecture RTL of TEMPMUX is
begin
  process (DISPLAY_SELECT, CURRENT_TEMP, DESIRED_TEMP)
  begin
    if DISPLAY_SELECT = '1' then
      TEMP_DISPLAY <= CURRENT_TEMP;
    else
      TEMP_DISPLAY <= DESIRED_TEMP;
    end if;
  end process;

end RTL;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.09.2022 16:18:50
-- Design Name: 
-- Module Name: tempmux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TEMPMUX is
port(   CURRENT_TEMP    : in bit_vector( 6 downto 0);
        DESIRED_TEMP    : in bit_vector( 6 downto 0);
        DISPLAY_SELECT  : in bit;
        TEMP_DISPLAY    : out bit_vector( 6 downto 0)
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

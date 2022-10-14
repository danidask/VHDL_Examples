library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blinky_ex01 is
    Port (  clk: in  STD_LOGIC;
            btnC: in  STD_LOGIC;
            led5: out  STD_LOGIC
            );
end blinky_ex01;

architecture Behavioral of blinky_ex01 is
	signal clk_counter : natural range 0 to 500000 := 0;
	signal blinker : std_logic := '0';
begin
	
	process(clk, btnC)
	begin 
		if rising_edge(clk) then 
			clk_counter <= clk_counter + 1; 
			if clk_counter >= 500000 then 
			  blinker <= not blinker;
			  clk_counter <= 0;
			end if; 
		end if; 
	end process;
	
	-- led5 <= blinker;
	led5 <= btnC;
end Behavioral;

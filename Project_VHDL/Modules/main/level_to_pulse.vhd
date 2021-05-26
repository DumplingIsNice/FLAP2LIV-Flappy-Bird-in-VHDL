--	LEVEL_TO_PULSE
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	Summary
--
--		Convert a change rising edge in level to a
--		one clk long pulse. Useful for buttons and
--		reset on FSMs.

LIBRARY IEEE;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_1164.all;

ENTITY level_to_pulse IS
	PORT (
		clk, d	: IN STD_LOGIC;
		q			: OUT STD_LOGIC
	);
END ENTITY level_to_pulse;

ARCHITECTURE behaviour OF level_to_pulse IS
	SIGNAL d_tick_behind	: STD_LOGIC	:= '0';
BEGIN

	PROCESS (clk) IS
	BEGIN
		if (rising_edge(clk)) then
			d_tick_behind <= d;
			if (d = '1' and d_tick_behind = '0') then
				q <= '1';
			else
				q <= '0';
			end if;
		end if;
	END PROCESS;
	
END behaviour;
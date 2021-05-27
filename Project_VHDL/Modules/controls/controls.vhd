-- WARNING: OUTDATED, UNUSED


-- CONTROLS
-- IN: <mouse_controls>
-- OUT: Graphics, Tracker

-- The Controls module monitors inputs from the user, via mouse or
-- on-board controls (buttons, DIP switches, etc).
-- On input events it interprets the input in the context of the game,
-- and generates commands for the Graphics and Tracker modules.

-- The Graphics module needs to know when the mouse clicks, so that
-- it can apply a transform to the position of the bird.
-- The Controls module needs to know when the game is paused.



-- TEMP: proof for DIP switch, ssg, and button

LIBRARY IEEE;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_1164.all;

ENTITY controls IS
	PORT(
		button		: IN STD_LOGIC;
		switch		: IN STD_LOGIC;
		ssg			: OUT STD_LOGIC_VECTOR(3 downto 0) := "0000");
END ENTITY controls;

ARCHITECTURE a OF controls IS
BEGIN
	ssg(0) <= '1' when (button = '0' and switch = '0') else '0';
	ssg(1) <= '1' when (button = '0' and switch = '1') else '0';
END ARCHITECTURE a;
-- MAIN
-- IN: Controls
-- OUT: GUI

-- Opening state machine for selecting a mode and beginning the game.
-- Instigates gameplay loop.

-- INPUTS:
--		game_mode : in std_logic		-- from Controls module, DIP switch
--		start : in std_logic			-- from Controls module, button
--		mouse position ... : in ...		-- from Controls module, for interacting with GUI
--		mouse_click ... : in ...		-- from Controls module, for interacting with GUI
-- OUTPUTS:
--		start : out std_logic			-- starts game loop
--		game_mode : out std_logic		-- TRAINING/GAME mode (changes to it are ignored when in game loop)
--		render_data ... : ...			-- to GUI module, to draw font and vectors on screen

--- Library ---
library IEEE;
use IEEE.std_logic_1164.all;

--- MAINMENU ---
entity MAINMENU is
	port(clk : in std_logic;
		game_mode : in std_logic;
		start : in std_logic;
		game_mode_out : out std_logic;
		start_out : out std_logic);
end entity MAINMENU;
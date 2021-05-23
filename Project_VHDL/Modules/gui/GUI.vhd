--	GRAPHICS
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	In:			TRACKER		(game state, lives left, etc.)
--
--	Out:			GUI_FEED		(outputs rbg values for each pixel)
--
--	Summary
--
--		GUI contextually generates the nature of the content to be displayed.
--		Commands are then sent to GUI_FEED, which inteprets them to generate
--		the required font_queue.
--
--		Contextual information comes from TRACKER (e.g. lives left, game state)
--		and the main menu screen also hosted by the GUI. 
--
--		GUI features include:
--		* Pause/Unpause splash text
--		* Lives left
--		* Current difficulty or score

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;


ENTITY gui IS
	PORT(
		clk, vert_sync					: IN STD_LOGIC;
		mouse_lclick					: IN STD_LOGIC;
		mouse_col, mouse_row			: IN STD_LOGIC_VECTOR(9 downto 0);
		score								: IN STD_LOGIC_VECTOR(7 downto 0);
		difficulty_level				: IN STD_LOGIC_VECTOR(1 downto 0);
		
		enable_mouse					: OUT STD_LOGIC	:= '1';
		enable_bird						: OUT STD_LOGIC	:= '0';
		select_test, select_game	: OUT STD_LOGIC;
		show_menu						: OUT STD_LOGIC
	);
END ENTITY gui;


ARCHITECTURE behaviour OF gui IS
	-- Variables
	SIGNAL v_show_menu				: STD_LOGIC := '1';
	
	-- Main Menu Constants
	CONSTANT PLAY_BTN_ROW			: STD_LOGIC_VECTOR(9 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(175,10));
	CONSTANT PLAY_BTN_COL			: STD_LOGIC_VECTOR(9 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(255,10));
	CONSTANT PLAY_BTN_SCALE			: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(16,6));
	CONSTANT PLAY_BTN_LENGTH		: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(1,6));
	CONSTANT TEST_BTN_ROW			: STD_LOGIC_VECTOR(9 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(400,10));
	CONSTANT TEST_BTN_COL			: STD_LOGIC_VECTOR(9 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(23,10));
	CONSTANT TEST_BTN_SCALE			: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
	CONSTANT TEST_BTN_LENGTH		: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
	CONSTANT GAME_BTN_ROW			: STD_LOGIC_VECTOR(9 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(400,10));
	CONSTANT GAME_BTN_COL			: STD_LOGIC_VECTOR(9 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(327,10));
	CONSTANT GAME_BTN_SCALE			: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
	CONSTANT GAME_BTN_LENGTH		: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
	
	-- f_BOUNDS_EVAL
	-- Returns true if the current pixel position is inside the given bounds.
	PURE FUNCTION f_BOUNDS_EVAL (
		col, row					: STD_LOGIC_VECTOR(9 downto 0);
		col_left, row_upper	: STD_LOGIC_VECTOR(9 downto 0);
		scale						: STD_LOGIC_VECTOR(5 downto 0);
		horizontal_length		: STD_LOGIC_VECTOR(5 downto 0);
		is_square				: STD_LOGIC)
		RETURN BOOLEAN IS
		VARIABLE b				: BOOLEAN;
		VARIABLE s_col,s_row : STD_LOGIC_VECTOR(9 downto 0);
	BEGIN
		s_row := "0" & scale & "000";	-- shift left 3 (x8)
		s_col := STD_LOGIC_VECTOR(UNSIGNED(s_row) * UNSIGNED("0000" & horizontal_length))(9 downto 0);
		if (is_square = '1') then
			s_row := s_col;
		end if;
		
		if (UNSIGNED(col) >= UNSIGNED(col_left) and UNSIGNED(col) <= (UNSIGNED(col_left) + UNSIGNED(s_col))
		and UNSIGNED(row) >= UNSIGNED(row_upper) and UNSIGNED(row) <= (UNSIGNED(row_upper) + UNSIGNED(s_row))) then
			b := TRUE;
		else
			b := FALSE;
		end if;
		return b;
	END FUNCTION f_BOUNDS_EVAL;
	
BEGIN
	
	show_menu <= v_show_menu;
	
	on_click: PROCESS (clk)
	BEGIN
		if (rising_edge(clk)) then
			if (mouse_lclick = '1') then
				if (v_show_menu = '1') then
					if (F_BOUNDS_EVAL(mouse_col, mouse_row, PLAY_BTN_COL, PLAY_BTN_ROW, PLAY_BTN_SCALE, PLAY_BTN_LENGTH, '1')) then
						-- Start game/play
						v_show_menu		<= '0';
						enable_bird		<= '1';
						enable_mouse	<= '0';
					elsif (F_BOUNDS_EVAL(mouse_col, mouse_row, TEST_BTN_COL, TEST_BTN_ROW, TEST_BTN_SCALE, TEST_BTN_LENGTH, '0')) then
						-- Set mode TRAINING
						select_test 	<= '1';
						select_game 	<= '0';
					elsif (F_BOUNDS_EVAL(mouse_col, mouse_row, GAME_BTN_COL, GAME_BTN_ROW, GAME_BTN_SCALE, GAME_BTN_LENGTH, '0')) then
						-- Set mode GAME
						select_game 	<= '1';
						select_test 	<= '0';
					end if;
				end if;
			end if;
		end if;
	END PROCESS on_click;

END behaviour;







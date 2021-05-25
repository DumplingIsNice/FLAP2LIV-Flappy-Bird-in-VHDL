--	GUI_FEED
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	In:			
--
--	Out:			
--
--	Summary
--
--		GUI_FEED is a wrapper for setting predetermined font queue packet values.
--		


LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;

USE work.graphics_pkg.all;


ENTITY gui_feed IS
	PORT(
		clk, vert_sync					: IN STD_LOGIC;
		--enable_mouse, enable_bird	: IN STD_LOGIC;
		mouse_col, mouse_row			: IN STD_LOGIC_VECTOR(9 downto 0);
		bird_col, bird_row			: IN STD_LOGIC_VECTOR(9 downto 0);
		
		enable_mouse, enable_bird	: IN STD_LOGIC;
		select_test, select_game	: IN STD_LOGIC;
		show_menu						: IN STD_LOGIC;
		show_pause						: IN STD_LOGIC;
		
		score, top_score				: IN STD_LOGIC_VECTOR(7 downto 0);
		difficulty_level				: IN STD_LOGIC_VECTOR(1 downto 0);
		lives								: IN STD_LOGIC_VECTOR(1 downto 0);
		
		f_cols									: OUT FONT_COLS		:= (others => (others => '0'));
		f_rows									: OUT FONT_ROWS		:= (others => (others => '0'));
		f_scales									: OUT FONT_SCALES		:= (others => (others => '0'));
		f_addresses								: OUT FONT_ADDRESSES	:= (others => (others => '0'));	
		f_red, f_green, f_blue				: OUT FONT_COLOUR;	-- );
		
		-- temporary for testing; will be replaced by GENERATOR:
		obj_cols_left, obj_cols_right		: OUT OBJ_COLS			:= (others => (others => '0'));
		obj_rows_upper, obj_rows_lower	: OUT OBJ_ROWS			:= (others => (others => '0'));
		obj_types								: OUT OBJ_TYPES		:= (others => (others => '0'));
		obj_red, obj_green, obj_blue		: OUT OBJ_COLOURS		:= (others => (others => '0')));
END ENTITY gui_feed;
	


ARCHITECTURE behaviour OF gui_feed IS
	SIGNAL mouse_scale, bird_scale		: std_logic_vector(5 downto 0)	:= (others => '0');
	
		-- Main Menu Constants
	CONSTANT TITLE_SCALE				: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
	CONSTANT PLAY_BTN_SCALE			: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(16,6));
	CONSTANT TEST_BTN_SCALE			: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
	CONSTANT GAME_BTN_SCALE			: STD_LOGIC_VECTOR(5 downto 0)	:= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
BEGIN

--	-- TEMP: to be replaced by GENERATOR after testing:
--	obj_cols_left(0)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(500,10));
--	obj_cols_right(0)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(560,10));
--	obj_rows_upper(0)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(0,10));
--	obj_rows_lower(0)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(220,10));
--	obj_red(0)			<= "1111";
--	obj_green(0)		<= "1111";
--	obj_blue(0)			<= "0000";
--	
--	obj_cols_left(1)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(500,10));
--	obj_cols_right(1)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(560,10));
--	obj_rows_upper(1)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(320,10));
--	obj_rows_lower(1)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(479,10));
--	obj_red(1)			<= "1111";
--	obj_green(1)		<= "1111";
--	obj_blue(1)			<= "0000";
--	
--	obj_cols_left(2)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(600,10));
--	obj_cols_right(2)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(620,10));
--	obj_rows_upper(2)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(260,10));
--	obj_rows_lower(2)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(300,10));
--	obj_red(2)			<= "1111";
--	obj_green(2)		<= "1111";
--	obj_blue(2)			<= "0000";


	-- Mouse Cursor
	f_scales(0) <= mouse_scale;
	f_addresses(0) <= CURSOR_ADDRESS;
	f_red(0)		<= "1111";
	f_green(0)	<=	"0000";
	f_blue(0)	<=	"0000";
	-- Bird Sprite
	f_scales(1) <= bird_scale;
	f_addresses(1) <= BIRD_ADDRESS;
	f_red(1)		<=	"0000";
	f_green(1)	<=	"0000";
	f_blue(1)	<=	"1111";
	
	
-- Updates BIRD position
-- Only update mouse position each frame, to prevent screen tearing
-- Bird has dedicated position 1 in queue (2nd priority)!
--	Set scale to 0 to hide.
set_bird_pos: PROCESS (vert_sync)
BEGIN
	if (rising_edge(vert_sync)) then
		f_cols(1) <= STD_LOGIC_VECTOR(TO_UNSIGNED(400,10));	-- bird_cols;
		f_rows(1) <= bird_row;
		
		if (enable_bird = '1') then
			bird_scale <= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
		else
			bird_scale <= STD_LOGIC_VECTOR(TO_UNSIGNED(0,6));
		end if;
	end if;
END PROCESS set_bird_pos;
	
	
-- Updates MOUSE position
-- Only update mouse position each frame, to prevent screen tearing
-- Mouse has dedicated position 0 in queue (priority)!
--	Set scale to 0 to hide.
set_mouse_pos: PROCESS(vert_sync)
BEGIN
	if(rising_edge(vert_sync)) then
		f_cols(0) <= mouse_col;
		f_rows(0) <= mouse_row;
		
		if (enable_mouse = '1') then
			mouse_scale <= STD_LOGIC_VECTOR(TO_UNSIGNED(4,6));
		else
			mouse_scale <= STD_LOGIC_VECTOR(TO_UNSIGNED(0,6));
		end if;
	end if;
END PROCESS set_mouse_pos;

generate_queue: PROCESS (vert_sync)
	VARIABLE lives_address	: STD_LOGIC_VECTOR(5 downto 0)	:= (others => '0');
BEGIN
	if (rising_edge(vert_sync)) then
		if (show_menu = '1') then
			-- MAIN MENU GUI --
			for i in 2 to 11 loop
				f_red(i)		<=	"1111";
				f_green(i)	<=	"1111";
				f_blue(i)	<=	"1111";
			end loop;
			
			-- Title
			for i in 2 to 10 loop
				f_rows(i)		<= STD_LOGIC_VECTOR(TO_UNSIGNED(31,10));
				f_scales(i)		<= TITLE_SCALE;
			end loop;
			
			f_cols(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(31,10));	-- 31
			f_addresses(2)		<= F_ADDRESS;
			f_cols(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(95,10));	-- 31 + (8*8*1)
			f_addresses(3)		<= L_ADDRESS;
			f_cols(4)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(159,10));	-- 31 + (8*8*2)
			f_addresses(4)		<= A_ADDRESS;
			f_cols(5)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(223,10));	-- 31 + (8*8*3)
			f_addresses(5)		<= P_ADDRESS;
			f_cols(6)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(287,10));	-- 31 + (8*8*4)
			f_addresses(6)		<= TWO_ADDRESS;
			f_cols(7)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(351,10));	-- 31 + (8*8*5)
			f_addresses(7)		<= L_ADDRESS;
			f_cols(8)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(415,10));	-- 31 + (8*8*6)
			f_addresses(8)		<= I_ADDRESS;
			f_cols(9)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(479,10));	-- 31 + (8*8*7)
			f_addresses(9)		<= V_ADDRESS;
			f_cols(10)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(543,10));	-- 31 + (8*8*8)
			f_addresses(10)	<= E_ADDRESS;
			
			-- Play Button
			f_cols(11)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(255,10));
			f_rows(11)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(175,10));
			f_addresses(11)	<= RIGHT_ARROW_ADDRESS;
			f_scales(11)		<= PLAY_BTN_SCALE;
			
			-- Test Button
			for i in 12 to 17 loop
				f_rows(i)		<= STD_LOGIC_VECTOR(TO_UNSIGNED(400,10));
				f_scales(i)		<= TEST_BTN_SCALE;
			end loop;
			if (select_test = '1') then
				for i in 12 to 17 loop
					f_red(i)		<=	"1100";
					f_green(i)	<=	"1100";
					f_blue(i)	<=	"0000";
				end loop;
			else
				for i in 12 to 17 loop
					f_red(i)		<=	"1111";
					f_green(i)	<=	"1111";
					f_blue(i)	<=	"1111";
				end loop;
			end if;
			f_cols(12)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(23,10));	-- 23
			f_addresses(12)	<= SQUARE_BRACKET_OPEN_ADDRESS;
			f_cols(13)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(71,10));	-- 23 + (6*8*1)
			f_addresses(13)	<= T_ADDRESS;
			f_cols(14)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(119,10));	-- 23 + (6*8*2)
			f_addresses(14)	<= E_ADDRESS;
			f_cols(15)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(167,10));	-- 23 + (6*8*3)
			f_addresses(15)	<= S_ADDRESS;
			f_cols(16)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(215,10));	-- 23 + (6*8*4)
			f_addresses(16)	<= T_ADDRESS;
			f_cols(17)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(263,10));	-- 23 + (6*8*5)
			f_addresses(17)	<= SQUARE_BRACKET_CLOSE_ADDRESS;
			
			-- Game Button
			for i in 18 to 23 loop
				f_rows(i)		<= STD_LOGIC_VECTOR(TO_UNSIGNED(400,10));
				f_scales(i)		<= GAME_BTN_SCALE;
			end loop;
			if (select_game = '1') then
				for i in 18 to 23 loop
					f_red(i)		<=	"1100";
					f_green(i)	<=	"1100";
					f_blue(i)	<=	"0000";
				end loop;
			else
				for i in 18 to 23 loop
					f_red(i)		<=	"1111";
					f_green(i)	<=	"1111";
					f_blue(i)	<=	"1111";
				end loop;
			end if;
			f_cols(18)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(327,10));	-- 327
			f_addresses(18)	<= SQUARE_BRACKET_OPEN_ADDRESS;
			f_cols(19)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(375,10));	-- 327 + (6*8*1)
			f_addresses(19)	<= G_ADDRESS;
			f_cols(20)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(423,10));	-- 327 + (6*8*2)
			f_addresses(20)	<= A_ADDRESS;
			f_cols(21)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(471,10));	-- 327 + (6*8*3)
			f_addresses(21)	<= M_ADDRESS;
			f_cols(22)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(519,10));	-- 327 + (6*8*4)
			f_addresses(22)	<= E_ADDRESS;
			f_cols(23)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(567,10));	-- 327 + (6*8*5)
			f_addresses(23)	<= SQUARE_BRACKET_CLOSE_ADDRESS;

		else
			-- GAMEPLAY GUI
			for i in 4 to 23 loop
				f_scales(i)	<= STD_LOGIC_VECTOR(TO_UNSIGNED(0,6));		-- hide all other packets when not needed
			end loop;
			
			
			-- Heart
			f_cols(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(515,10)); -- 639 - (60 + 8*8)
			f_rows(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
			f_scales(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
			f_addresses(2)		<= HEART_ADDRESS;
			f_red(2)				<=	"1111";
			f_green(2)			<=	"1111";
			f_blue(2)			<=	"1111";
			-- Lives
			case lives is
				when "00" =>	lives_address := o"60";
				when "01" =>	lives_address := o"61";
				when "10" =>	lives_address := o"62";
				when others =>	lives_address := o"63";
			end case;
			
			f_cols(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(579,10));	-- 639 - 60
			f_rows(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
			f_scales(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
			f_addresses(3)		<= lives_address;
			f_red(3)				<=	"1111";
			f_green(3)			<=	"1111";
			f_blue(3)			<=	"1111";
			
		end if;
	end if;

END PROCESS generate_queue;

END ARCHITECTURE behaviour;
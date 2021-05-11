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
		clk, vert_sync				: IN STD_LOGIC;
		mouse_cols, mouse_rows	: IN STD_LOGIC_VECTOR(9 downto 0);
		bird_cols, bird_rows		: IN STD_LOGIC_VECTOR(9 downto 0);
		
		f_cols						: OUT FONT_COLS			:= (others => (others => '0'));
		f_rows						: OUT FONT_ROWS			:= (others => (others => '0'));
		f_scales						: OUT FONT_SCALES			:= (others => (others => '0'));
		f_addresses					: OUT FONT_ADDRESSES		:= (others => (others => '0'));
		
		f_red, f_green, f_blue	: OUT FONT_COLOUR);
END ENTITY gui_feed;
	


ARCHITECTURE behaviour OF gui_feed IS
BEGIN

	-- Mouse Cursor
	f_scales(0) <= STD_LOGIC_VECTOR(TO_UNSIGNED(4,6));
	f_addresses(0) <= CURSOR_ADDRESS;
	f_red(0)		<= "1111";
	f_green(0)	<=	"0000";
	f_blue(0)	<=	"0000";
	-- Bird Sprite
	f_scales(1) <= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
	f_addresses(1) <= BIRD_ADDRESS;
	f_red(1)		<=	"0000";
	f_green(1)	<=	"0000";
	f_blue(1)	<=	"1111";
	
	-- Static
	-- A
	f_cols(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_rows(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_scales(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
	f_addresses(2)		<= A_ADDRESS;
	f_red(2)		<=	"1111";
	f_green(2)	<=	"1111";
	f_blue(2)	<=	"1111";
	-- B
	f_cols(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(124,10)); -- 60 + 8*8
	f_rows(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_scales(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
	f_addresses(3)		<= B_ADDRESS;
	f_red(3)		<=	"1111";
	f_green(3)	<=	"1111";
	f_blue(3)	<=	"1111";
	-- C
	f_cols(4)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(188,10)); -- 60 + 2*8*8
	f_rows(4)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_scales(4)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
	f_addresses(4)		<= C_ADDRESS;
	f_red(4)		<=	"1111";
	f_green(4)	<=	"1111";
	f_blue(4)	<=	"1111";
	
	
-- Updates BIRD position
-- Only update mouse position each frame, to prevent screen tearing
-- Bird has dedicated position 1 in queue (2nd priority)!
set_bird_pos: PROCESS (vert_sync)
BEGIN
	if (rising_edge(vert_sync)) then
		f_cols(1) <= STD_LOGIC_VECTOR(TO_UNSIGNED(400,10));	-- bird_cols;
		f_rows(1) <= bird_rows;
	end if;
END PROCESS set_bird_pos;
	
-- Updates MOUSE position
-- Only update mouse position each frame, to prevent screen tearing
-- Mouse has dedicated position 0 in queue (priority)!
set_mouse_pos: PROCESS(vert_sync)
BEGIN
	if(rising_edge(vert_sync)) then
		f_cols(0) <= mouse_cols;
		f_rows(0) <= mouse_rows;
	end if;
END PROCESS set_mouse_pos;

END ARCHITECTURE behaviour;
LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;

USE work.graphics_pkg.all;


ENTITY vga_feed IS
	PORT(
		clk, vert_sync				: IN STD_LOGIC;
		mouse_cols, mouse_rows	: IN STD_LOGIC_VECTOR(9 downto 0);
		bird_cols, bird_rows		: IN STD_LOGIC_VECTOR(9 downto 0);
		
		f_cols						: OUT FONT_COLS			:= (others => (others => '0'));
		f_rows						: OUT FONT_ROWS			:= (others => (others => '0'));
		f_scales						: OUT FONT_SCALES			:= (others => (others => '0'));
		f_addresses					: OUT FONT_ADDRESSES		:= (others => (others => '0')));
END ENTITY vga_feed;
	


ARCHITECTURE a OF vga_feed IS
BEGIN

	f_scales(0) <= STD_LOGIC_VECTOR(TO_UNSIGNED(4,6));
	f_addresses(0) <= CURSOR_ADDRESS;
	
	f_scales(1) <= STD_LOGIC_VECTOR(TO_UNSIGNED(6,6));
	f_addresses(1) <= BIRD_ADDRESS;
	
	-- Static
	-- A
	f_cols(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_rows(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_scales(2)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
	f_addresses(2)		<= A_ADDRESS;
	-- B
	f_cols(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(124,10)); -- 60 + 8*8
	f_rows(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_scales(3)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
	f_addresses(3)		<= B_ADDRESS;
	-- C
	f_cols(4)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(188,10)); -- 60 + 2*8*8
	f_rows(4)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(60,10));
	f_scales(4)			<= STD_LOGIC_VECTOR(TO_UNSIGNED(8,6));
	f_addresses(4)		<= C_ADDRESS;
	
	
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

END ARCHITECTURE a;
--	GRAPHICS
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	In:			GUI			(inputs mouse, bird, fonts, and other overlay rendering packets)
--					GENERATOR	(inputs background and obstacles)
--					VGA_SYNC		(update each pixel depending on pixel position)
--
--	Out:			VGA_SYNC		(outputs rbg values for each pixel)
--					COLLISION	(description)
--
--	Summary
--
--		GRAPHICS determines the rgb values for each pixel using the given column
--		and row positioning. It overlays the background and obstacles layer with
--		fonts from the GUI font_queue.
--		Note that queue position 0 is reserved for the mouse cursor, and position
--		1 for the bird sprite.
--
--		See GRAPHICS_PKG for more information on font queues and packets.


LIBRARY IEEE;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_1164.all;

USE work.graphics_pkg.all;





ENTITY graphics IS
	PORT(
		clk, vert_sync				: IN STD_LOGIC;
		pixel_row, pixel_column	: IN STD_LOGIC_VECTOR(9 downto 0);
		
		f_cols						: IN FONT_COLS;
		f_rows						: IN FONT_ROWS;
		f_scales						: IN FONT_SCALES;
		f_addresses					: IN FONT_ADDRESSES;
		f_red, f_green, f_blue	: IN FONT_COLOUR;
		
		obj_r, obj_g, obj_b		: IN FONT_COLOUR_PACKET;
		
		rom_output					: IN STD_LOGIC;
		rom_address					: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		rom_row, rom_col			: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		
		r,g,b							: OUT FONT_COLOUR_PACKET);
END ENTITY graphics;


ARCHITECTURE behaviour OF graphics IS
	SIGNAL vr,vg,vb								: FONT_COLOUR_PACKET		:= (others => '0');
--	SIGNAL vr,vg,vb,vr_t,vg_t,vb_t			: FONT_COLOUR_PACKET		:= (others => '0');
--	SIGNAL vr_bird,vg_bird,vb_bird			: FONT_COLOUR_PACKET		:= (others => '0');
--	SIGNAL vr_cursor,vg_cursor,vb_cursor	: FONT_COLOUR_PACKET		:= (others => '0');

	-- f_BOUNDS_EVAL
	-- Returns true if the current pixel position is inside the given bounds.
	-- Bounds are col->col+(8*scale), row->row+(8*scale)
	FUNCTION f_BOUNDS_EVAL (
		col, row, f_col, f_row	: STD_LOGIC_VECTOR(9 downto 0);
		scale							: STD_LOGIC_VECTOR(5 downto 0))
		RETURN BOOLEAN IS
		VARIABLE b		: BOOLEAN;
		VARIABLE s		: STD_LOGIC_VECTOR(9 downto 0);
	BEGIN
		s := "0" & scale & "000";	-- shift left 3 (x8)
		if ((UNSIGNED(col) >= UNSIGNED(f_col)) and (UNSIGNED(col) < UNSIGNED(f_col) + UNSIGNED(s))
		and (UNSIGNED(row) >= UNSIGNED(f_row)) and (UNSIGNED(row) < UNSIGNED(f_row) + UNSIGNED(s))) then
			b := TRUE;
		else
			b := FALSE;
		end if;
		return b;
	END FUNCTION f_BOUNDS_EVAL;
	
	-- f_FONT_EVAL
	-- Evaluate pixel using font bitmap
	IMPURE FUNCTION f_FONT_EVAL (
		col, row, f_col, f_row	: STD_LOGIC_VECTOR(9 downto 0);
		scale, address				: STD_LOGIC_VECTOR(5 downto 0))
		RETURN BOOLEAN IS
		VARIABLE b		: BOOLEAN;
	BEGIN
		rom_address	<= address;
		rom_col		<= STD_LOGIC_VECTOR(UNSIGNED(UNSIGNED(col) - UNSIGNED(f_col))/UNSIGNED(scale))(2 downto 0);
		rom_row		<= STD_LOGIC_VECTOR(UNSIGNED(UNSIGNED(row) - UNSIGNED(f_row))/UNSIGNED(scale))(2 downto 0);
		if (rom_output = '1') then
			b := TRUE;
		else
			b := FALSE;
		end if;
		return b;
	END FUNCTION f_FONT_EVAL;
	
		
BEGIN

	r <= vr;
	g <= vg;
	b <= vb;
		
	-- Set r,g,b for every pixel (updating for each change in row or col)
	pixel_eval: PROCESS (pixel_column)
	BEGIN
		if (rising_edge(pixel_column(0))) then
			
			vr <= obj_r;
			vg <= obj_g;
			vb <= obj_b;
			
			-- Loop downwards such that lower indices have overwrite priority
			for k in FONT_QUEUE_LENGTH downto 0 loop
				if (F_BOUNDS_EVAL(pixel_column, pixel_row, f_cols(k), f_rows(k), f_scales(k))) then
					if (F_FONT_EVAL(pixel_column, pixel_row, f_cols(k), f_rows(k), f_scales(k), f_addresses(k))) then
						vr <= f_red(k);
						vg <= f_green(k);
						vb <= f_blue(k);
					end if;
				end if;
			end loop;	
			
		end if;
					
	--		-- FRAMEWORK FOR CHANNEL PRIORITY MUX FIX
	--		-- NOTE: Uses mux to choose between two different rgb values so font channels can overlap.
	--		-- WARNING: Signals should only be driven from one source. Need to use more signals to decouple.
	--
	--		if (F_BOUNDS_EVAL(pixel_column, pixel_row, f_cols(0), f_rows(0), f_scales(0))) then
	--			if (F_FONT_EVAL(pixel_column, pixel_row, f_cols(0), f_rows(0), f_scales(0), f_addresses(0))) then
	--				vr_cursor <= f_red(0);
	--				vg_cursor <= f_green(0);
	--				vb_cursor <= f_blue(0);
	--				cursor_flag := '1';
	--			else
	--				cursor_flag := '0';
	--		end if;
	--		
	--		-- MUX priority channels
	--		if (cursor_flag = '1') then
	--			vr <= vr_cursor;
	--			vg <= vg_cursor;
	--			vb <= vb_cursor;
	--		end if;

	END PROCESS pixel_eval;


-- FRAMEWORK FOR ROM 'GHOST PIXEL' FIX
-- NOTE: Requires changes to CHAR_ROM and requisite inputs here
--
--t_bounds_eval: PROCESS(pixel_column)
--	VARIABLE index : integer;
--	VARIABLE temp_column, temp_row : STD_LOGIC_VECTOR(9 downto 0);
--BEGIN
--	if (rising_edge(pixel_column(0))) then
--		-- [1]	Evaluate the bounds to get the address of the highest priority overlapped font
--		index := 25;
--		for k in FONT_QUEUE_LENGTH downto 0 loop
--			if (F_BOUNDS_EVAL(temp_column, temp_row, f_cols(k), f_rows(k), f_scales(k))) then
--				index := k;
--			end if;
--		end loop;
--		
--		-- [2]	Load ROM with correct values for current font
--		if (index /= 25) then
--			F_FONT_EVAL(temp_column, temp_row, f_cols(k), f_rows(k), f_scales(k), f_addresses(k));
--		end if;
--	end if;
--END PROCESS t_bounds_eval;
--	
--t_font_eval: PROCESS(rom_flag)
--BEGIN
--	-- [3]	Once the ROM has output a value, complete the evaluation of rgb
--	if (rising_edge(rom_flag)) then
--		vr <= f_red(k)		when rom_output = '1'	else (others => '0');
--		vg <= f_green(k)	when rom_output = '1'	else (others => '0');
--		vb <= f_blue(k)	when rom_output = '1'	else (others => '0');
--	end if;
--END PROCESS t_font_eval;


END behaviour;
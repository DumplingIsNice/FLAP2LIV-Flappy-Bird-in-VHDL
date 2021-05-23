--	GRAPHICS_OBJECTS
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	In:			GENERATOR	(inputs background and obstacles)
--					VGA_SYNC		(update each pixel depending on pixel position)
--
--	Out:			VGA_SYNC		(outputs rbg values for each pixel)
--					COLLISION	(description)
--
--	Summary
--
--		GRAPHICS_OBJECTS processes the object queue before sending the final rgb
--		values to GRAPHICS, where the UI font queue is overlayed.
--		Overlapping obstacles are not supported. The queue is evaluated with
--		ascending indices, the lower values having greater priority. Thus 0 has
--		the greatest priority.
--
--		Each obstacle takes the form of a vector rectangle perpendicular to the
--		edges of the screen. If a custom sprite with collision is needed, create
--		an object packet with rgb values of the background colour. Then create a
--		font packet to be overlayed in the same position as the sprite. 
--
--		See GRAPHICS_PKG for more information on font queues and packets.


LIBRARY IEEE;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_1164.all;

USE work.graphics_pkg.all;


ENTITY graphics_objects IS
	PORT(
		clk, vert_sync							: IN STD_LOGIC;
		disable_render							: IN STD_LOGIC;
		pixel_row, pixel_column				: IN STD_LOGIC_VECTOR(9 downto 0);
		
		obj_cols_left, obj_cols_right		: IN OBJ_COLS;
		obj_rows_upper, obj_rows_lower	: IN OBJ_ROWS;
		obj_types								: IN OBJ_TYPES;
		obj_red, obj_green, obj_blue		: IN OBJ_COLOURS;
		
		r,g,b										: OUT FONT_COLOUR_PACKET;
		collision_type							: OUT std_logic_vector(3 downto 0));
END ENTITY graphics_objects;



ARCHITECTURE behaviour OF graphics_objects IS
	SIGNAL vr, vg, vb							: FONT_COLOUR_PACKET	:= (others => '0');

	-- f_BOUNDS_EVAL
	-- Returns true if the current pixel position is inside the given bounds.
	PURE FUNCTION f_BOUNDS_EVAL (
		col, row					: STD_LOGIC_VECTOR(9 downto 0);
		col_left, col_right	: STD_LOGIC_VECTOR(9 downto 0);
		row_upper, row_lower	: STD_LOGIC_VECTOR(9 downto 0))
		RETURN BOOLEAN IS
		VARIABLE b				: BOOLEAN;
	BEGIN
		if (UNSIGNED(col) >= UNSIGNED(col_left) and UNSIGNED(col) <= UNSIGNED(col_right)
		and UNSIGNED(row) >= UNSIGNED(row_upper) and UNSIGNED(row) <= UNSIGNED(row_lower)) then
			b := TRUE;
		else
			b := FALSE;
		end if;
		return b;
	END FUNCTION f_BOUNDS_EVAL;
	
BEGIN
	-- disable render is LOW=ON to take advantage of the inverse relationship with show_menu from GUI
	r <= vr when (disable_render = '0') else (others => '0');
	g <= vg when (disable_render = '0') else (others => '0');
	b <= vb when (disable_render = '0') else (others => '0');

	pixel_eval: PROCESS (pixel_column)
	BEGIN
		if(rising_edge(pixel_column(0))) then
		
			vr <= (others => '0');
			vg <= (others => '0');
			vb <= (others => '0');
			-- no overlap support; object with the lowest indices takes priority
			for k in 0 to OBJ_QUEUE_LENGTH loop
				if (F_BOUNDS_EVAL(pixel_column, pixel_row, obj_cols_left(k), obj_cols_right(k), obj_rows_upper(k), obj_rows_lower(k))) then
					vr <= obj_red(k);
					vg <= obj_green(k);
					vb <= obj_blue(k);
					collision_type <= obj_types(k);
					exit;
				end if;
			end loop;
			
		end if;
	END PROCESS pixel_eval;

END behaviour;


--	COLLISION
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	In:			GENERATOR	(inputs obstacles vector positions and types)
--					PHYSICS		(bird sprite position)
--
--	Out:			TRACKER		(collision flag and type to apply corresponding effects)
--
--	Summary
--
--		COLLISION determines when and if a collision ocurrs between the player
--		controlled sprite and any of the obstacles.
--
--		The type of collision is returned (to distinguish collisions with pipes or
--		pickups), in addition to a collision_flag that goes high for a period of one
--		frame. The bird hitbox is a point at the center of the sprite. Obstacle hitboxes
--		are evaluated in their vector entirety.
--
--		Each request is a packet of the form:
--		[col, row, scale, address, r, g, b]
--
--		col and row:	denote the top left corner of the font render (where to begin).
--		scale:			denotes what the bitmap should be multiplied by (at 1, 8x8 -> 8x8)
--		address:			is the address in CHAR_ROM ROM memory of the font 8x8 bitmap
--		r,g,b:			the colour the font should be rendered in (overrides previous values)
--
--		As VHDL synthesis has limited array dimension support we split the packet into
--		1D arrays of equal size (queue length), and access the relevant data in parallel.

LIBRARY IEEE;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_1164.all;

USE work.graphics_pkg.all;


ENTITY collision IS
	PORT (
		clk, vert_sync							: IN STD_LOGIC;
		bird_col, bird_row					: IN STD_LOGIC_VECTOR(9 downto 0);
		obj_cols_left, obj_cols_right		: IN OBJ_COLS;
		obj_rows_upper, obj_rows_lower	: IN OBJ_ROWS;
		obj_types								: IN OBJ_TYPES;
	
		collision_flag							: OUT STD_LOGIC;
		collision_type							: OUT OBJ_TYPE_PACKET
	);
END ENTITY collision;



ARCHITECTURE behaviour OF collision IS
	-- Offset shifts collision point from top left corner to center
	-- Offset is 1/2 of 8*scale (scale is 6)
	CONSTANT SPRITE_OFFSET					: UNSIGNED(9 downto 0)		:= TO_UNSIGNED(24,10);
	
	-- f_BOUNDS_EVAL
	-- Returns true if the current pixel position is inside the given bounds.
	PURE FUNCTION f_BOUNDS_EVAL (
		col, row					: UNSIGNED(9 downto 0);
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

	eval_collision: PROCESS (vert_sync) IS
	BEGIN
		if (rising_edge(vert_sync)) then
			for k in 0 to OBJ_QUEUE_LENGTH loop
				if (f_BOUNDS_EVAL(UNSIGNED(bird_col) + SPRITE_OFFSET, UNSIGNED(bird_row) + SPRITE_OFFSET, obj_cols_left(k), obj_cols_right(k), obj_rows_upper(k), obj_rows_lower(k))
				or (UNSIGNED(bird_col) < UPPER_COLLISION) or UNSIGNED(bird_col) > LOWER_COLLISION) then
					collision_flag <= '1';
					collision_type <= obj_types(k);
					exit;
				else
					collision_flag <= '0';
					collision_type <= (others => '0');
				end if;
			end loop;
		end if;
	END PROCESS eval_collision;


END behaviour;

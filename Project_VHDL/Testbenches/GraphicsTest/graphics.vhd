LIBRARY IEEE;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_1164.all;


USE work.graphics_pkg.all;


ENTITY graphics IS
	PORT(
		clk, vert_sync				: IN STD_LOGIC;
		
		f_cols						: IN FONT_COLS;
		f_rows						: IN FONT_ROWS;
		f_scales						: IN FONT_SCALES;
		f_addresses					: IN FONT_ADDRESSES;
		
		rom_output					: IN STD_LOGIC;
		rom_address					: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		rom_row, rom_col			: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		
		pixel_row, pixel_column	: IN STD_LOGIC_VECTOR(9 downto 0);
		r,g,b							: OUT STD_LOGIC);
END ENTITY graphics;


ARCHITECTURE behaviour OF graphics IS
	SIGNAL vr, vg, vb				: STD_LOGIC := '0';
	
	-- f_BOUNDS_EVAL
	-- Returns true if the current pixel position is inside the given bounds.
	-- Bounds are col->col+(8*scale), row->row+(8*scale)
	FUNCTION f_BOUNDS_EVAL (
		col, row, f_col, f_row	: STD_LOGIC_VECTOR(9 downto 0);
		scale, address				: STD_LOGIC_VECTOR(5 downto 0))
		RETURN BOOLEAN IS
		VARIABLE b		: BOOLEAN;
		VARIABLE s		: STD_LOGIC_VECTOR(9 downto 0);
	BEGIN
		s := "0" & scale & "000";	-- shift left 3 (x8)
		if ((UNSIGNED(col) > UNSIGNED(f_col)) and (UNSIGNED(col) < UNSIGNED(f_col) + UNSIGNED(s))
		and (UNSIGNED(row) > UNSIGNED(f_row)) and (UNSIGNED(row) < UNSIGNED(f_row) + UNSIGNED(s))) then
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
	
	
-- for each pixel (col, then row) perform ifs for font_queue
-- modularise these checks into a function


-- Set r,g,b for every pixel (updating for each change in row or col)
pixel_eval: PROCESS(clk, pixel_row, pixel_column)
BEGIN
	if (rising_edge(pixel_column(0))) then
		vr <= '0';
		vg <= '0';
		vb <= '0';
		
		-- For each packet in the font queue:
		-- (lower numbers have higher priority, 0 overwrites all)
		if (F_BOUNDS_EVAL(pixel_column, pixel_row, f_cols(4), f_rows(4), f_scales(4), f_addresses(4))) then
			if (F_FONT_EVAL(pixel_column, pixel_row, f_cols(4), f_rows(4), f_scales(4), f_addresses(4))) then
				vr <= '0';
				vg <= '1';
				vb <= '1';
			end if;
		end if;
		if (F_BOUNDS_EVAL(pixel_column, pixel_row, f_cols(3), f_rows(3), f_scales(3), f_addresses(3))) then
			if (F_FONT_EVAL(pixel_column, pixel_row, f_cols(3), f_rows(3), f_scales(3), f_addresses(3))) then
				vr <= '0';
				vg <= '1';
				vb <= '1';
			end if;
		end if;
		if (F_BOUNDS_EVAL(pixel_column, pixel_row, f_cols(2), f_rows(2), f_scales(2), f_addresses(2))) then
			if (F_FONT_EVAL(pixel_column, pixel_row, f_cols(2), f_rows(2), f_scales(2), f_addresses(2))) then
				vr <= '0';
				vg <= '1';
				vb <= '1';
			end if;
		end if;
		if (F_BOUNDS_EVAL(pixel_column, pixel_row, f_cols(1), f_rows(1), f_scales(1), f_addresses(1))) then
			if (F_FONT_EVAL(pixel_column, pixel_row, f_cols(1), f_rows(1), f_scales(1), f_addresses(1))) then
				vr <= '0';
				vg <= '1';
				vb <= '0';
			end if;
		end if;
		if (F_BOUNDS_EVAL(pixel_column, pixel_row, f_cols(0), f_rows(0), f_scales(0), f_addresses(0))) then	
			if (F_FONT_EVAL(pixel_column, pixel_row, f_cols(0), f_rows(0), f_scales(0), f_addresses(0))) then
				vr <= '1';
				vg <= '0';
				vb <= '0';
			end if;
		end if;	
	end if;
END PROCESS pixel_eval;




END behaviour;
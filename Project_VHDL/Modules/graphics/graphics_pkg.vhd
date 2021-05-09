--	GRAPHICS_PKG
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	Summary
--
--		GRAPHICS_PKG is the shared format for sending, storing, and
--		accessing font render requests.
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


LIBRARY	IEEE;
USE		IEEE.STD_LOGIC_1164.all;

PACKAGE graphics_pkg IS

	-- Constants
CONSTANT CURSOR_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"77";
CONSTANT BIRD_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"76";

CONSTANT A_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := "000001";	-- address: 01row
CONSTANT B_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := "000010";	-- address: 02row
CONSTANT C_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := "000011";	-- address: 03row





	-- Break up font packet [col, row, scale, address] into 1D arrays for synthesis
CONSTANT FONT_QUEUE_LENGTH	: INTEGER := 23;

TYPE font_cols			IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(9 downto 0);
TYPE font_rows			IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(9 downto 0);
TYPE font_scales		IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(5 downto 0);
TYPE font_addresses	IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(5 downto 0);

TYPE font_red			IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(3 downto 0);
TYPE font_green		IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(3 downto 0);
TYPE font_blue			IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(3 downto 0);



END PACKAGE graphics_pkg;
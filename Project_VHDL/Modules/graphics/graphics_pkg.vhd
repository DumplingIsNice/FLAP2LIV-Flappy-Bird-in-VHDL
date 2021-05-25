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
USE 	IEEE.STD_LOGIC_ARITH.all;

PACKAGE graphics_pkg IS

	-- FONT --
	-- Break up font packet [col, row, scale, address] into 1D arrays for synthesis
CONSTANT FONT_QUEUE_LENGTH	: INTEGER := 23;

TYPE font_cols			IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(9 downto 0);
TYPE font_rows			IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(9 downto 0);
TYPE font_scales		IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(5 downto 0);
TYPE font_addresses	IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF std_logic_vector(5 downto 0);

SUBTYPE font_colour_packet IS std_logic_vector(3 downto 0);
TYPE font_colour		IS ARRAY (FONT_QUEUE_LENGTH downto 0) OF FONT_COLOUR_PACKET;


	-- OBJECT --
	-- Each object queue has packets [col_left, row_upper, col_right, row_lower, type, r, g, b]
	-- left,upper describes the point the vector rectangle begins.
	-- right,lower describes the point the vector rectangle ends.
CONSTANT OBJ_QUEUE_LENGTH : INTEGER := 23;
	
TYPE obj_cols			IS ARRAY (OBJ_QUEUE_LENGTH downto 0) OF std_logic_vector(9 downto 0);
TYPE obj_rows			IS ARRAY (OBJ_QUEUE_LENGTH downto 0) OF std_logic_vector(9 downto 0);

SUBTYPE obj_type_packet IS std_logic_vector(3 downto 0);
TYPE obj_types			IS ARRAY (OBJ_QUEUE_LENGTH downto 0) OF OBJ_TYPE_PACKET;
TYPE obj_colours		IS ARRAY (OBJ_QUEUE_LENGTH downto 0) OF FONT_COLOUR_PACKET;

	-- OBJECT HELPERS --
	-- (3, 2) = top coordinate (col, row), (1, 0) = bot coordinate (col, row)
TYPE obj_pos 			IS ARRAY (3 downto 0) OF STD_LOGIC_VECTOR (9 downto 0);
TYPE obj_mem 			IS ARRAY(OBJ_QUEUE_LENGTH downto 0) OF OBJ_POS;

CONSTANT OBJ_POS_ALL_ZERO	: obj_pos := (others => "0000000000");
CONSTANT GAP_FACTOR 			: STD_LOGIC_VECTOR(6 downto 0)	:= CONV_STD_LOGIC_VECTOR(10, 7);
CONSTANT BORDER_MARGIN 		: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(40, 10);
CONSTANT GAP_HEIGHT 			: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(96, 10);

CONSTANT SCREEN_TOP			: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(0, 10);
CONSTANT SCREEN_BOT			: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(640, 10);
CONSTANT SCREEN_LEFT			: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(0, 10);
CONSTANT SCREEN_RIGHT		: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(480, 10);

CONSTANT PIPE_WIDTH 			: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(40, 10);
CONSTANT DIS_BETWEEN_PIPE 	: INTEGER := 120;
CONSTANT PIPE_TYPE			: OBJ_TYPE_PACKET						:= "0000";
CONSTANT PIPE_COLOUR			: FONT_COLOUR_PACKET					:= "0000";

CONSTANT DEFAULT_SPEED		: INTEGER 								:= 5;
CONSTANT SPEED_INC			: INTEGER 								:= 10;


	-- CONSTANTS --
CONSTANT CURSOR_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"77";
CONSTANT BIRD_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"76";

CONSTANT HEART_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"74";

CONSTANT A_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"01";
CONSTANT B_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"02";
CONSTANT C_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"03";
CONSTANT D_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"04";
CONSTANT E_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"05";
CONSTANT F_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"06";
CONSTANT G_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"07";
CONSTANT H_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"10";
CONSTANT I_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"11";
CONSTANT J_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"12";
CONSTANT K_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"13";
CONSTANT L_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"14";
CONSTANT M_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"15";
CONSTANT N_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"16";
CONSTANT O_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"17";
CONSTANT P_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"20";
CONSTANT Q_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"21";
CONSTANT R_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"22";
CONSTANT S_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"23";
CONSTANT T_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"24";
CONSTANT U_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"25";
CONSTANT V_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"26";
CONSTANT W_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"27";
CONSTANT X_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"30";
CONSTANT Y_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"31";
CONSTANT Z_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"32";
CONSTANT SPACE_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"40";

CONSTANT SQUARE_BRACKET_OPEN_ADDRESS	: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"33";
CONSTANT SQUARE_BRACKET_CLOSE_ADDRESS	: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"35";
CONSTANT DOWN_ARROW_ADDRESS				: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"34";
CONSTANT UP_ARROW_ADDRESS					: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"36";
CONSTANT RIGHT_ARROW_ADDRESS				: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"37";

CONSTANT ZERO_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"60";
CONSTANT ONE_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"61";
CONSTANT TWO_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"62";
CONSTANT THREE_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"63";
CONSTANT FOUR_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"64";
CONSTANT FIVE_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"65";
CONSTANT SIX_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"66";
CONSTANT SEVEN_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"67";
CONSTANT EIGHT_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"70";
CONSTANT NINE_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := o"71";

END PACKAGE graphics_pkg;
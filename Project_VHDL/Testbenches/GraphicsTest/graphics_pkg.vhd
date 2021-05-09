library IEEE;
use  IEEE.STD_LOGIC_1164.all;

-- Record structures for Graphics module

PACKAGE graphics_pkg IS


CONSTANT CURSOR_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := "111111";	-- address: 77row
CONSTANT BIRD_ADDRESS		: STD_LOGIC_VECTOR (5 DOWNTO 0) := "111110";	-- address: 76row

CONSTANT A_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := "000001";	-- address: 01row
CONSTANT B_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := "000010";	-- address: 02row
CONSTANT C_ADDRESS			: STD_LOGIC_VECTOR (5 DOWNTO 0) := "000011";	-- address: 03row





-- Break up font packet [col, row, scale, address] into 1D arrays for synthesis
TYPE font_cols			IS ARRAY (23 downto 0) OF std_logic_vector(9 downto 0);
TYPE font_rows			IS ARRAY (23 downto 0) OF std_logic_vector(9 downto 0);
TYPE font_scales		IS ARRAY (23 downto 0) OF std_logic_vector(5 downto 0);
TYPE font_addresses	IS ARRAY (23 downto 0) OF std_logic_vector(5 downto 0);



-- OBSOLETE ------>
TYPE font_vector IS RECORD
	col_pos	: STD_LOGIC_VECTOR (9 downto 0);	-- x: 0->599
	row_pos	: STD_LOGIC_VECTOR (9 downto 0);	-- y: 0->479
	scale		: STD_LOGIC_VECTOR (5 downto 0);	-- font scale (@1:8x8,@2:16x16)
	address	: STD_LOGIC_VECTOR (5 downto 0);	-- 
END RECORD;
END PACKAGE graphics_pkg;
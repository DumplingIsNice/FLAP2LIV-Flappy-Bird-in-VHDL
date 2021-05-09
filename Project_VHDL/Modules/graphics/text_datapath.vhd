-- This component is the datapath for feeding the correct information to char-rom
-- To fetch the appropriate rom_mux_output for the current pixel position on the window.

    -- Input: The current pixel position on the display window from VGA_sync.
    -- Outputs: All necessary information for char_rom to output a rom_mux_output
    -- (font_row, font_col, address), the scale output is for debugging purposes only.

-- Position of each character to be displayed on screen is currently defined 
-- as a FONT_CHAR record in text_pkg.vhd

-- NOTE: x -> col, y -> row

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

USE work.text_pkg.all;

ENTITY text_datapath IS
	PORT
	(
		-- character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		row, col	        :	IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		clock				: 	IN STD_LOGIC;
		font_row, font_col  :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        scale               :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        o_address           :   OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
	);
END text_datapath;

ARCHITECTURE path OF text_datapath IS

    -- Intermediate output signals.
    SIGNAL	i_font_row, i_font_col  : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL  i_scale                 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL  i_o_address             : STD_LOGIC_VECTOR (5 DOWNTO 0);

    -- Procedure for checking whether the current window pixel psition lies in of of our
    -- defined x, y position of a character.
    -- If yes, began cell_check. Else skip.
    PROCEDURE LIMIT_CHECK
        (   
            SIGNAL row, col                   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            SIGNAL char                       : IN FONT_CHAR;
            SIGNAL font_row, font_col         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            SIGNAL scale                      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            SIGNAL o_address                  : OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
        ) IS

        variable col_relative : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 10); 
        variable row_relative : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 10); 

    BEGIN 

        IF (((char.x <= col) and (col <= (char.x + 7)*char.scale)) 
            and 
            ((char.y <= row) and (row <= (char.y + 7)*char.scale))) THEN

            col_relative := col - char.x;
            row_relative := row - char.y;

            font_col <= col_relative(2 downto 0);
            font_row <= row_relative(2 downto 0);
            scale <= char.scale;
            o_address <= char.address;
        ELSE
            font_col <= CONV_STD_LOGIC_VECTOR(0, i_font_col'LENGTH);
            font_row <= CONV_STD_LOGIC_VECTOR(0, i_font_row'LENGTH);
            scale <= CONV_STD_LOGIC_VECTOR(0, i_scale'LENGTH);
            o_address <= CONV_STD_LOGIC_VECTOR(0, i_o_address'LENGTH);
        END IF;

    END PROCEDURE LIMIT_CHECK;

    SIGNAL a_1 : FONT_CHAR;

BEGIN

    a_1 <= CHAR_A;

    PROCESS (clock)
    BEGIN
        IF (rising_edge(clock)) THEN
            -- Output varification, dubugging
            -- i_font_col <= a_1.x;
            -- i_font_row <= a_1.y;
            -- i_scale <= a_1.scale;
            -- i_o_address <= a_1.address;
            LIMIT_CHECK(
                        row, col, a_1, 
                        i_font_row, i_font_col, i_scale, i_o_address
                        );
        END IF;
    end PROCESS;

    font_row <= i_font_row;
    font_col <= i_font_col;
    scale <= i_scale;
    o_address <= i_o_address;

END path;
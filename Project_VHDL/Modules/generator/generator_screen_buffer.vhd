-- GENERATOR_SCREEN_BUFFER

-- IN: Generator
-- OUT: Graphics

-- Block in memory that stores predetermined data to be sent to the VGA output.
-- Predetermined data includes background imagery and obstacles (including collision
-- bool layer). The bird sprite and GUI are overlayed in the Graphics module.

-- It works as a shift register, moving along a set number of pixels each frame.
-- Only the Generator module writes to this memory block.
-- The Graphics module reads this block, sending pixel columns overlapping with the bird
-- sprite to the Collision module, and overwriting pixels with GUI content and bird sprite
-- before sending the final composite to the VGA output module.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;

USE work.graphics_pkg.all;

ENTITY generator_screen_buffer IS
	PORT(
			read_data, reset 						: IN STD_LOGIC;
			obj_cols_top, obj_cols_bot				: IN OBJ_COLS;
			obj_rows_top, obj_rows_bot				: IN OBJ_ROWS;
			object_type								: IN OBJ_TYPE;
			obj_colour_r							: IN OBJ_COLOUR;
			obj_colour_g							: IN OBJ_COLOUR;
			obj_colour_b							: IN OBJ_COLOUR;

            obj_cols_top_out, obj_cols_bot_out		: OUT OBJ_COLS			:= (others => (others => '0'));
			obj_rows_top_out, obj_rows_bot_out		: OUT OBJ_ROWS			:= (others => (others => '0'));
			obj_type_out							: OUT OBJ_TYPE			:= (others => (others => '0'));
			obj_colour_r_out						: OUT OBJ_COLOUR 		:= (others => (others => '0'));
			obj_colour_g_out						: OUT OBJ_COLOUR 		:= (others => (others => '0'));
			obj_colour_b_out						: OUT OBJ_COLOUR 		:= (others => (others => '0'))
        );
END ENTITY generator_screen_buffer;

ARCHITECTURE behaviour OF generator_screen_buffer IS
	SIGNAL obj_cols_top_i, obj_cols_bot_i			: OBJ_COLS			:= (others => (others => '0'));
	SIGNAL obj_rows_top_i, obj_rows_bot_i			: OBJ_ROWS			:= (others => (others => '0'));
	SIGNAL object_type_i							: OBJ_TYPE			:= (others => (others => '0'));
	SIGNAL object_colour_i							: OBJ_COLOUR		:= (others => (others => '0'));
	SIGNAL obj_colour_r_i							: OBJ_COLOUR 		:= (others => (others => '0'));
	SIGNAL obj_colour_g_i							: OBJ_COLOUR 		:= (others => (others => '0'));
	SIGNAL obj_colour_b_i							: OBJ_COLOUR 		:= (others => (others => '0'));
BEGIN

	PROCESS(read_data, reset)
	BEGIN
		IF (reset = '1') THEN
			obj_cols_top_i 		<= (others => "0000000000");
			obj_rows_top_i 		<= (others => "0000000000");
			obj_cols_bot_i 		<= (others => "0000000000");
			obj_rows_bot_i 		<= (others => "0000000000");
			object_type_i	 	<= (others => "0000");
			obj_colour_r_i		<= (others => (others => '0'));
			obj_colour_g_i		<= (others => (others => '0'));
			obj_colour_b_i		<= (others => (others => '0'));
		END IF;

		IF (RISING_EDGE(read_data)) THEN
			obj_cols_top_i 		<= obj_cols_top;
			obj_rows_top_i 		<= obj_rows_top;
			obj_cols_bot_i 		<= obj_cols_top;
			obj_rows_bot_i 		<= obj_rows_top;
			object_type_i	 	<= object_type;
			obj_colour_r_i		<= (others => (others => '0'));
			obj_colour_g_i		<= (others => (others => '0'));
			obj_colour_b_i		<= (others => (others => '0'));
		END IF;
	END PROCESS;

	obj_cols_top_out 	<= obj_cols_top_i;
	obj_rows_top_out 	<= obj_rows_top_i;
	obj_cols_bot_out 	<= obj_cols_top_i;
	obj_rows_bot_out 	<= obj_rows_top_i;
	obj_type_out	 	<= object_type_i;
	obj_colour_r_out	<= obj_colour_r_i;
	obj_colour_g_out	<= obj_colour_g_i;
	obj_colour_b_out	<= obj_colour_b_i;

END ARCHITECTURE behaviour;
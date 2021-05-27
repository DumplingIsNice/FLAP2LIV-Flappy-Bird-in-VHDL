-- GENERATOR

--	Authors:		Hao Lin
--	Date:			May 2021
--	Course:		CS305 Miniproject

--	In:			TRACKER		(difficulty parameters and state control signals to control object generation)				 
-- 				RAND_NUM 	(5-bit random number for random elements)
--					VGA_SYNC		(vert_sync as object update signal)
-- 								NOTE: This module is driven by vert_sync.
--
--	Out:			GENERATOR_BUFFER (To be held constant for a screen refresh)

--	Summary
--
--	 The Generator module generates the background layout and obstacles
--	 using simple alogorithms and RNG, and outputs a queue of the
--	 composite image.
--	
--	 Output queues is in the format of OBJ_QUEUE_LENGTHx1 pixel 
--	 pixel columns to be sent each frame. Where each idex position
--	 corresponds to a object whihc exist. The content of each position
--	 is a 10-bit value of the corner coordinates of the object's 
--	 position on screen. This position (in pairs of top and bottem
--	 coordinates) is phased by GRAPHICS to draw the object.
--	
--	 The colour queue take the format of OBJ_QUEUE_LENGTHxFONT_COLOUR_PACKET.
--	 FOR GRAPHIC display.
--	
--	 The type queue tke the format of OBJ_QUEUE_LENGTHxTYPE_PACKET. 
--	 For COLLISION calculation.
--	
--	 See GRAPHICS_PKG for more information on font queues and packets
--	
--	 TRACKER's RELATIONSHIP
--	
--	 The TRACKER module stores the current difficulty, which influences:
--		-- * Background colour scheme (and perhaps pattern)
--		-- * Obstacle (barrier) patterns and frequency
--		-- * Obstacle (barrier) colour scheme and sprite shape
--		-- * Pickup frequency and type
--	 In this GENERATION module.
--	
--	 New generation begins when the screen is refreshed (vert_sync).
--	 As the speed varies, generation will be irregular, and on-demand. 
--	 There is a blank space between each obstacle column, so generation
--	 does not have to be continuous (we have the time to repopulate the
--	 buffer before each refresh).
--	
--	 NOTE: For more complex sprites it may be cheaper to have a pool of mapped,
--	 pre-defined bitmaps for objects, rather than trying to generate with vectors.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
-- USE IEEE.NUMERIC_STD.all;

USE work.graphics_pkg.all;

ENTITY generator IS
	PORT(
			vert_sync, enable, reset	: IN STD_LOGIC;
			difficulty						: IN STD_LOGIC_VECTOR(1 downto 0);
			rand_num							: IN STD_LOGIC_VECTOR(4 downto 0);

			score_flag						: OUT STD_LOGIC		:= '0';
			obj_cols_left, obj_cols_right	: OUT OBJ_COLS			:= (others => (others => '0'));
			obj_rows_top, obj_rows_bot	: OUT OBJ_ROWS			:= (others => (others => '0'));
			object_type						: OUT OBJ_TYPES 		:= (others => (others => '0'));
			obj_colour_r					: OUT OBJ_COLOURS 	:= (others => (others => '0'));
			obj_colour_g					: OUT OBJ_COLOURS 	:= (others => (others => '0'));
			obj_colour_b					: OUT OBJ_COLOURS 	:= (others => (others => '0'))
        );
END ENTITY generator;

ARCHITECTURE behaviour OF generator IS
	-- Loads a set of positon data into the next memory array
	PROCEDURE LOAD_OBJ
        (   
			VARIABLE obj_data_pos 								: IN obj_pos;
			VARIABLE obj_data_type								: IN obj_type_packet;
			VARIABLE obj_r, obj_g, obj_b 						: IN font_colour_packet;
			
			VARIABLE mem_index 									: INOUT INTEGER;
			VARIABLE is_scored									: OUT IS_SCORED_ARRAY;
			SIGNAL top_cols, top_rows, bot_cols, bot_rows 		: OUT obj_cols;
			SIGNAL object_type									: OUT obj_types;
			SIGNAL obj_colour_r, obj_colour_g, obj_colour_b		: OUT OBJ_COLOURS
        ) IS

    BEGIN 
		top_cols(mem_index) 		<= obj_data_pos(3);
		top_rows(mem_index) 		<= obj_data_pos(2);
		bot_cols(mem_index) 		<= obj_data_pos(1);
		bot_rows(mem_index) 		<= obj_data_pos(0);
		
		object_type(mem_index)		<= obj_data_type;
		obj_colour_r(mem_index) 	<= obj_r;
		obj_colour_g(mem_index) 	<= obj_g;
		obj_colour_b(mem_index) 	<= obj_b;

		IF (obj_data_type = PIPE_TYPE) THEN
			is_scored(mem_index) := '0';
		ELSE
			is_scored(mem_index) := '1';
		END IF;

        IF (mem_index = 0) THEN
			mem_index := OBJ_QUEUE_LENGTH;
        ELSE
			mem_index := mem_index - 1;
        END IF;

    END PROCEDURE LOAD_OBJ;

	-- Updates the col value of all non-zero item of the memory array
	PROCEDURE UPDATE_OBJ
        (   
			VARIABLE speed 										: IN STD_LOGIC_VECTOR(9 downto 0);
			VARIABLE mem_index 									: IN INTEGER;
			SIGNAL top_cols, top_rows, bot_cols, bot_rows 		: INOUT obj_cols;
			SIGNAL obj_colour_r, obj_colour_g, obj_colour_b		: OUT OBJ_COLOURS;
			VARIABLE is_scored									: INOUT IS_SCORED_ARRAY;
			SIGNAL score_flag									: INOUT STD_LOGIC
        ) IS

		VARIABLE current_obj	: obj_pos := OBJ_POS_ALL_ZERO;
    BEGIN 
		FOR index IN (OBJ_QUEUE_LENGTH) downto 0 LOOP
			IF  (
					not(top_cols(index) = TEN_BIT_ALL_ZERO AND
						top_rows(index) = TEN_BIT_ALL_ZERO AND
						bot_cols(index) = TEN_BIT_ALL_ZERO AND
						bot_rows(index) = TEN_BIT_ALL_ZERO)
				) THEN

				-- From obj_pos TYPE in graphics_pkg.vhd:
				-- (3, 2) = top coordinate (col, row), (1, 0) = bot coordinate (col, row)

				-- Bin objects which have left the screen.
				IF (bot_cols(index) <= TEN_BIT_ALL_ZERO or bot_cols(index) > SCREEN_RIGHT) THEN
					top_cols(index) <= TEN_BIT_ALL_ZERO;
					top_rows(index) <= TEN_BIT_ALL_ZERO;
					bot_cols(index) <= TEN_BIT_ALL_ZERO;
					bot_rows(index) <= TEN_BIT_ALL_ZERO;

					obj_colour_r(index) <= OBJ_COLOUR_ZERO;
					obj_colour_g(index) <= OBJ_COLOUR_ZERO;
					obj_colour_b(index) <= OBJ_COLOUR_ZERO;
				ELSE
					-- Increment object location

					-- Col of top coordinate remains at SCREEN_LEFT
					-- When it has reached SCREEN_LEFT and beyond
					-- (not within 0 to SCREEN_RIGHT)
					IF (top_cols(index) /= TEN_BIT_ALL_ZERO or not(top_cols(index) <= SCREEN_RIGHT)) THEN
						top_cols(index) <= top_cols(index) - speed;
					ELSIF (top_cols(index) = TEN_BIT_ALL_ZERO or top_cols(index) > SCREEN_RIGHT) THEN
						top_cols(index) <= TEN_BIT_ALL_ZERO;
					END IF;
					-- Col of bottem coordinate remains at SCREEN_RIGHT 
					-- until PIP_WIDTH have been reached.
					IF ((SCREEN_RIGHT - top_cols(index)) >= PIPE_WIDTH) THEN
						bot_cols(index) <= bot_cols(index) - speed;
					END IF;
				END IF;

				-- Fires score_flag when passing right edge of pipe, shuts off on next frame.
				IF (bot_cols(index) <= BIRD_POSITION AND is_scored(index) = '0') THEN
					is_scored(index) := '1';
					score_flag <= '1';
				ELSIF (score_flag = '1') THEN
					score_flag <= '0';
				END IF;
			END IF;
		END LOOP;
    END PROCEDURE UPDATE_OBJ;

	SIGNAL top_cols, top_rows, bot_cols, bot_rows 	: obj_cols 	:= 	OBJ_COLS_ALL_ZERO;
	SIGNAL score_flag_i 							: STD_LOGIC := 	'0';
BEGIN
	-- Object generation
	-- Interesting problem: Results always seemed to be delayed b 1/T. Yet it scales with T.
	OBJ_CREATION: PROCESS(vert_sync, reset, enable)
		VARIABLE pipe_top, pipe_bot 				: obj_pos 						:= OBJ_POS_ALL_ZERO;
		VARIABLE gap_top, gap_bot, gap_pos			: STD_LOGIC_VECTOR(9 downto 0) 	:= CONV_STD_LOGIC_VECTOR(0, 10);
		VARIABLE pipe_top_type, pipe_bot_type		: obj_type_packet				:= PIPE_TYPE;
		VARIABLE pipe_r, pipe_g, pipe_b				: obj_type_packet				:= OBJ_COLOUR_ZERO;
		VARIABLE intermediate 						: STD_LOGIC_VECTOR(11 downto 0) := CONV_STD_LOGIC_VECTOR(0, 12);

		VARIABLE pickup								: obj_pos 						:= OBJ_POS_ALL_ZERO;
		VARIABLE pickup_type						: obj_type_packet				:= NULL_TYPE;
		VARIABLE pickup_r, pickup_g, pickup_b		: obj_type_packet				:= OBJ_COLOUR_ZERO;
		VARIABLE pickup_sel							: STD_LOGIC_VECTOR(3 downto 0);
		VARIABLE location							: STD_LOGIC_VECTOR(9 downto 0)	:= PICKUP_TOP_ROW;

		VARIABLE mem_index 							: INTEGER 						:= OBJ_QUEUE_LENGTH;
		VARIABLE pipes_passed						: STD_LOGIC_VECTOR(1 downto 0)	:= CONV_STD_LOGIC_VECTOR(0, 2);
		VARIABLE dis_counter						: STD_LOGIC_VECTOR(9 downto 0) 	:= CONV_STD_LOGIC_VECTOR(DIS_BETWEEN_PIPE, 10);
		-- pixel/ver_sync
		VARIABLE speed 								: STD_LOGIC_VECTOR(9 downto 0) 	:= DEFAULT_SPEED;
		VARIABLE is_scored							: IS_SCORED_ARRAY := (others => '0');
	BEGIN

		IF (RISING_EDGE(vert_sync)) THEN
			IF (reset = '1') THEN
				top_cols <= (others => (others => '0'));
				top_rows <= (others => (others => '0'));
				bot_cols <= (others => (others => '0'));
				bot_rows <= (others => (others => '0'));
--				top_cols <= OBJ_COLS_ALL_ZERO;
--				top_rows <= OBJ_COLS_ALL_ZERO;
--				bot_cols <= OBJ_COLS_ALL_ZERO;
--				bot_rows <= OBJ_COLS_ALL_ZERO;
				score_flag <= '0';
				speed := DEFAULT_SPEED;
				mem_index := OBJ_QUEUE_LENGTH;
				dis_counter := CONV_STD_LOGIC_VECTOR(DIS_BETWEEN_PIPE, 10);
			END IF;

			IF (enable = '1') THEN
				-- Speed change based on difficulty.
				CASE(difficulty) is
					WHEN DIFF_0 => 
						speed := DEFAULT_SPEED;
					WHEN DIFF_1 => 
						speed := SPEED_1;
					WHEN DIFF_2 => 
						speed := SPEED_2;
					WHEN DIFF_3 => 
						speed := SPEED_3;
					WHEN others =>
						speed := speed;
				END CASE; 
				
				-- Update object
				dis_counter := dis_counter + speed;
				UPDATE_OBJ(	speed, 
							mem_index, 
							top_cols, top_rows, bot_cols, bot_rows, 
							obj_colour_r, obj_colour_g, obj_colour_b, 
							is_scored, score_flag_i);

				-- Pipe Creation
				IF (dis_counter >= CONV_STD_LOGIC_VECTOR(DIS_BETWEEN_PIPE, 10)) THEN
					dis_counter := CONV_STD_LOGIC_VECTOR(0, 10);

					-- Calculate pipe gap position
					intermediate := rand_num * GAP_FACTOR; -- Intermediate mulplication container register
					gap_pos := intermediate(9 downto 0); -- Tested
					
					gap_top := gap_pos + BORDER_MARGIN;
					gap_bot := gap_top + GAP_HEIGHT;

					IF (gap_bot >= SCREEN_BOT - BORDER_MARGIN) THEN
						gap_bot := SCREEN_BOT - BORDER_MARGIN;
					END IF;

					-- From obj_pos TYPE in graphics_pkg.vhd:
					-- (3, 2) = top coordinate (col, row), (1, 0) = bot coordinate (col, row)
					pipe_top(3) 	:= SCREEN_RIGHT; 
					pipe_top(2) 	:= SCREEN_TOP;
					pipe_top(1) 	:= SCREEN_RIGHT;
					pipe_top(0) 	:= gap_top; -- Top of gap to bottem coordinate of top pipe.
					pipe_top_type 	:= PIPE_TYPE;

					pipe_bot(3) 	:= SCREEN_RIGHT; 
					pipe_bot(2) 	:= gap_bot; -- Bottem of gap to top coordinate of bottem pipe.
					pipe_bot(1) 	:= SCREEN_RIGHT;
					pipe_bot(0) 	:= SCREEN_BOT; 
					pipe_bot_type 	:= PIPE_TYPE;

					pipe_r := OBJ_COLOUR_ZERO;
					pipe_g := "1111";
					pipe_b := OBJ_COLOUR_ZERO;

					-- Load real positional data into memory
					LOAD_OBJ(
								pipe_top, pipe_top_type, 
								pipe_r, pipe_g, pipe_b, 
								mem_index, 
								is_scored,
								top_cols, top_rows, bot_cols, bot_rows,
								object_type, 
								obj_colour_r, obj_colour_g, obj_colour_b);	
					LOAD_OBJ(
								pipe_bot, pipe_bot_type,
								pipe_r, pipe_g, pipe_b,
								mem_index,
								is_scored,
								top_cols, top_rows, bot_cols, bot_rows,
								object_type,
								obj_colour_r, obj_colour_g, obj_colour_b);
								
					pipes_passed := pipes_passed + CONV_STD_LOGIC_VECTOR(1, 2);

				-- Pickup object creation
				ELSIF (dis_counter >= HALF_DIS_BETWEEN_PIPE) THEN

					-- Minimum threshold of pipes passed before pickups are generatied.
					IF (pipes_passed > CONV_STD_LOGIC_VECTOR(2, 2)) THEN
						pipes_passed := CONV_STD_LOGIC_VECTOR(0, 2);
						
						-- Random number drived from 5-bit random number.
						pickup_sel := rand_num(3 downto 0);

						-- Currently fixed to 0 - 9; In the future, 6 numbers will be used as = no pickups.
						IF (pickup_sel >= CONV_STD_LOGIC_VECTOR(10, 4)) THEN
							pickup_sel := CONV_STD_LOGIC_VECTOR(0, 4);
						END IF;

						-- Probability evaluations for each type of pickup.
						IF ((CONV_STD_LOGIC_VECTOR(0, 4) <= pickup_sel) AND (pickup_sel < INVI_CHANCE)) THEN
							pickup_type := LIFE_TYPE;			-- have swapped +life and invuln effects for purposes of demo
							pickup_r := "1111";
							pickup_g := OBJ_COLOUR_ZERO;
							pickup_b := OBJ_COLOUR_ZERO;
						
--							pickup_type := INVI_TYPE;
--							pickup_r := OBJ_COLOUR_ZERO;
--							pickup_g := "1111";
--							pickup_b := "1111";
						ELSIF ((INVI_CHANCE <= pickup_sel) AND (pickup_sel < (LIFE_CHANCE+INVI_CHANCE))) THEN
							pickup_type := INVI_TYPE;
							pickup_r := OBJ_COLOUR_ZERO;
							pickup_g := "1111";
							pickup_b := "1111";
--							pickup_type := LIFE_TYPE;
--							pickup_r := "1111";
--							pickup_g := OBJ_COLOUR_ZERO;
--							pickup_b := OBJ_COLOUR_ZERO;
						ELSIF (((LIFE_CHANCE+INVI_CHANCE) <= pickup_sel) AND (pickup_sel < (LIFE_CHANCE+INVI_CHANCE+COLOUR_SH_CHANCE))) THEN
							pickup_type := COLOUR_SH_TYPE;
							pickup_r := OBJ_COLOUR_ZERO;
							pickup_g := OBJ_COLOUR_ZERO;
							pickup_b := "1111";
						ELSE
							pickup_type := NULL_TYPE;
						END IF;

						-- Pickup object creation
						IF (pickup_type /= NULL_TYPE) THEN
							CASE(pickup_sel(0)) IS 
								WHEN '0' => location := PICKUP_TOP_ROW;
								WHEN '1' => location := PICKUP_BOT_ROW;
								WHEN OTHERS => location := PICKUP_TOP_ROW;
							END CASE;
							
							pickup(3) := SCREEN_RIGHT;
							pickup(2) := location;
							pickup(1) := SCREEN_RIGHT;
							pickup(0) := pickup(2) +  CONV_STD_LOGIC_VECTOR(32, 10);

							LOAD_OBJ(
									pickup, pickup_type,
									pickup_r, pickup_g, pickup_b, -- Need colour informations?
									mem_index,
									is_scored,
									top_cols, top_rows, bot_cols, bot_rows,
									object_type,
									obj_colour_r, obj_colour_g, obj_colour_b);	
						END IF;
						pickup_type := NULL_TYPE;
					END IF;
				END IF;
			END IF;
			score_flag <= score_flag_i;
		END IF;
	END PROCESS OBJ_CREATION;
	
	UNPACK: PROCESS(top_cols, top_rows, bot_cols, bot_rows)
	BEGIN
		FOR index IN (OBJ_QUEUE_LENGTH) downto 0 LOOP
			obj_cols_left(index) <= top_cols(index);
			obj_rows_top(index) <= top_rows(index);
			obj_cols_right(index) <= bot_cols(index);
			obj_rows_bot(index) <= bot_rows(index);
		END LOOP;
	END PROCESS UNPACK;

END ARCHITECTURE behaviour;
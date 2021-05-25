-- GENERATOR_II

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;

USE work.graphics_pkg.all;


ENTITY generator_II IS
	PORT (
		clk, vert_sync							: IN STD_LOGIC;
		difficulty								: IN STD_LOGIC_VECTOR(1 downto 0);
		rand_num									: IN STD_LOGIC_VECTOR(4 downto 0);
	
		obj_cols_left, obj_cols_right		: OUT OBJ_COLS			:= (others => (others => '0'));
		obj_rows_upper, obj_rows_lower	: OUT OBJ_ROWS			:= (others => (others => '0'));
		obj_types								: OUT OBJ_TYPES		:= (others => (others => '0'));
		obj_red, obj_green, obj_blue		: OUT OBJ_COLOURS		:= (others => (others => '0'))	
	);
END ENTITY generator_II;


ARCHITECTURE behaviour OF generator_II IS
	SIGNAL shift_step_size					: UNSIGNED(2 downto 0)	:= TO_UNSIGNED(1,10);

	SIGNAL shift_clk							: STD_LOGIC;
	SIGNAL shift_clk_count_limit			: UNSIGNED(3 downto 0)	:= TO_UNSIGNED(10,4);	-- period (in frames) between each shift
	
	SIGNAL obstacle_clk, pickup_flag		: STD_LOGIC;
	SIGNAL obstacle_count_limit			: UNSIGNED(6 downto 0)	:= TO_UNSIGNED(59,7);	-- period (in frames) between each obstacle generation
	SIGNAL pickup_count_limit				: UNSIGNED(3 downto 0)	:= TO_UNSIGNED(3,4);		-- period (in obstacles) between each pickup
BEGIN

	
	-- TODO:
	
	-- * load to and read memory component (stores object_queue). Shift register? Otherwise rotating index.
	-- * rng generator component
	-- * row and gap positioning logic with 5 bit rng value (range 1->30).
	
	
	
	
	
	-- need memory component to store data in
	
	shift: PROCESS (shift_clk) IS
		VARIABLE temp							: STD_LOGIC_VECTOR (9 downto 0);
	BEGIN
		for k in OBJ_QUEUE_LENGTH downto 0 loop
			-- temp := cols(k);
			-- -- NOTE: we cannot simultaneously read and write to same location in memory. Store in temp first.
			-- cols(k) <= STD_LOGIC_VECTOR(UNSIGNED(temp) + UNSIGNED(shift_step_size));
		end loop;
	END PROCESS shift;


	set_count_limit: PROCESS(clk) IS
	BEGIN
		if (rising_edge(clk)) then
			case (difficulty) is
				when "00" =>
					shift_step_size				<= TO_UNSIGNED(1,3);	-- 2 pixels per
					shift_clk_count_limit		<= TO_UNSIGNED(0,4);	-- vert_sync divider
				when "01" =>
					shift_step_size				<= TO_UNSIGNED(2,3);	-- 3 pixels per
					shift_clk_count_limit		<= TO_UNSIGNED(0,4);	-- vert_sync divider
				when "10" =>
					shift_step_size				<= TO_UNSIGNED(3,3);	-- 4 pixels per
					shift_clk_count_limit		<= TO_UNSIGNED(0,4);	-- vert_sync divider
				when others =>
					shift_step_size				<= TO_UNSIGNED(4,3);	-- 5 pixels per
					shift_clk_count_limit		<= TO_UNSIGNED(0,4);	-- vert_sync divider
			end case;
		end if;
	END PROCESS set_count_limit;


	shift_clk <= vert_sync;
	
	shift_clk_gen: PROCESS(vert_sync) IS
		VARIABLE shift_clk_count				: UNSIGNED(3 downto 0);					-- min 1 shift every 16 frames, ~4 per second
		VARIABLE obstacle_counter				: UNSIGNED(6 downto 0);					-- max of 128 counts, ~2s between each obstacle
		VARIABLE pickup_counter					: UNSIGNED(3 downto 0);					-- min 1 pickup every 16 obstacles
	BEGIN

		if (rising_edge(vert_sync)) then
			-- Current disabled, to get best fps we are not using a clk divider for shifting
			-- shift_clk <= vert_sync
--			if (shift_clk_count >= shift_clk_count_limit) then
--				shift_clk_count			:= TO_UNSIGNED(0);
--				shift_clk					<= '1';
--			else
--				shift_clk_count			:= shift_clk_count + TO_UNSIGNED(1);
--				shift_clk					<= '0';
--			end if;
		
			if (obstacle_counter >= obstacle_count_limit) then
				obstacle_counter	:= TO_UNSIGNED(0,7);
				obstacle_clk		<= '1';
				if (pickup_counter >= pickup_count_limit) then
					pickup_counter	:= TO_UNSIGNED(0,7);
					pickup_flag		<= '1';
				else
					pickup_counter := pickup_counter + TO_UNSIGNED(1,4);
					pickup_flag		<= '0';
				end if;
			else
				obstacle_counter	:= obstacle_counter + TO_UNSIGNED(1,4);
				obstacle_clk		<= '0';
			end if;
		end if;
	END PROCESS shift_clk_gen;

END behaviour;


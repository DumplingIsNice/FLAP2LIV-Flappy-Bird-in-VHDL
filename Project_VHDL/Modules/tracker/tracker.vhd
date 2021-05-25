-- TRACKER
-- IN: Controls, Collision
-- OUT: Generator, GUI

-- The Tracker module stores and updates game information.
-- This includes the bird's lives, the score, the time,
-- difficulty stage, active effects, game state, etc.

-- The Tracker receives pause/unpause commands from the Controller,
-- changing the game's state, and collision events from the
-- Collision module, with which it can apply damage or pickup
-- effects.

-- The Tracker then sends this information to the GUI to display,
-- and to the generator as arguments (the generator needs to know
-- the current difficulty when generating obstacles and landscapes,
-- and must be disabled to pause the game).


LIBRARY IEEE;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_1164.all;

USE work.graphics_pkg.all;


ENTITY tracker IS
	PORT (
		clk, reset				: IN STD_LOGIC;
		oneHz_clk				: IN STD_LOGIC;
		
		select_test				: IN STD_LOGIC;
		score_clk				: IN STD_LOGIC;
		
		collision_flag			: IN STD_LOGIC;
		collision_type			: IN OBJ_TYPE_PACKET;
	
		lives						: OUT STD_LOGIC_VECTOR(1 downto 0);
		difficulty				: OUT STD_LOGIC_VECTOR(1 downto 0)	:= "00";
		score, top_score		: OUT UNSIGNED(7 downto 0);
				
		show_menu				: OUT STD_LOGIC	:= '1';
		show_pause				: OUT STD_LOGIC	:= '0';
		generator_enable		: OUT STD_LOGIC	:= '0';
		physics_enable			: OUT STD_LOGIC	:= '0';
		generator_reset		: OUT STD_LOGIC	:= '0';
		physics_reset			: OUT STD_LOGIC	:= '0'
	);
END ENTITY tracker;


ARCHITECTURE behaviour OF tracker IS
	SIGNAL v_score, v_top_score	: UNSIGNED(7 downto 0)	:= TO_UNSIGNED(0,8);
	SIGNAL v_lives						: UNSIGNED(1 downto 0)	:= TO_UNSIGNED(1,2);
	
	SIGNAl pause						: STD_LOGIC;				
	SIGNAL game_reset				: STD_LOGIC;
	
	TYPE STATE_TYPE is 				(S0,S1,S2);
	SIGNAL state, next_state		: STATE_TYPE;

BEGIN

	lives <= STD_LOGIC_VECTOR(v_lives);
	score <= v_score;
	top_score <= v_top_score;


	-- GAME STATE FSM --
	SYNC_PROC: process (clk)
	BEGIN
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= S0;
			else
				state <= next_state;
			end if;
		end if;
	END PROCESS SYNC_PROC;

	OUTPUT_DECODE: process (state)
	BEGIN	
		case (state) is
			when S0 =>
				-- GAMEOVER
				show_menu				<= '1';
				show_pause				<= '0';
				generator_enable		<= '0';
				physics_enable			<= '0';
				generator_reset		<= '1';
				physics_reset			<= '1';
				
				game_reset				<= '1';
			when S1 =>
				-- PAUSE
				show_menu				<= '0';
				show_pause				<= '1';
				generator_enable		<= '0';
				physics_enable			<= '0';
				generator_reset		<= '0';
				physics_reset			<= '0';
				
				game_reset				<= '0';
			when others =>
				-- RUN
				show_menu				<= '0';
				show_pause				<= '0';
				generator_enable		<= '1';
				physics_enable			<= '1';
				generator_reset		<= '0';
				physics_reset			<= '0';
				
				game_reset				<= '0';
		end case;
	END PROCESS OUTPUT_DECODE;

	NEXT_STATE_DECODE: process (state, pause, v_lives)
	BEGIN
		next_state <= S0;
		
		case (state) is
			when S0 =>
				next_state <= S1;
				--if (control input) then
				--	next_state <= S1;
				--end if;
			when S1 =>
				if (pause = '0') then
					next_state <= S2;
				end if;
			when others =>
				if (v_lives <= TO_UNSIGNED(1,2)) then
					next_state <= S0;
				elsif (pause = '1') then
					next_state <= S1;
				end if;
		end case;
	END PROCESS NEXT_STATE_DECODE;


	score_count: PROCESS (score_clk, game_reset)
	BEGIN
		if (game_reset = '1') then
			if (v_score > v_top_score) then
				v_top_score <= v_score;
			end if;
			v_score <= (others => '0');
		elsif (rising_edge(score_clk)) then
			v_score <= v_score + TO_UNSIGNED(1,8);
			
			if (select_test = '0') then
				if (v_score > DIFFICULTY_THRESHOLD_1) then
					difficulty <= "01";
				elsif (v_score > DIFFICULTY_THRESHOLD_2) then
					difficulty <= "10";
				elsif (v_score > DIFFICULTY_THRESHOLD_3) then
					difficulty <= "11";
				end if;
			end if;
		end if;
	END PROCESS score_count;
	
	
	on_collision: PROCESS (collision_flag, game_reset)
	BEGIN
		if (game_reset = '1') then
			v_lives <= TO_UNSIGNED(1,2);
		elsif (rising_edge(collision_flag)) then
			case collision_type is
				when "0000" =>
					-- Obstacle (damages)
					v_lives <= v_lives - TO_UNSIGNED(1,2);
					if (v_lives > TO_UNSIGNED(0,2)) then
						-- Apply invulnerability for a short period
					end if;
				when "0001" =>
					-- Invulnerability
				when "0010" =>
					-- Extra life
					v_lives <= v_lives + TO_UNSIGNED(1,2);
				when others =>
					-- Colour shift
			end case;
		end if;
	END PROCESS on_collision;


END behaviour;









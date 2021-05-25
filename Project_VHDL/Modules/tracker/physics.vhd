--	PHYSICS
--
--	Authors:		Callum McDowell
--	Date:			May 2021
--	Course:		CS305 Miniproject
--
--
--	In:			VGA_SYNC		(get vertical_sync to update each frame)
--					MOUSE			(apply 'jump' effect on lclick)
--
--	Out:			GUI			(send bird y position (row) for rendering)
--
--	Summary
--
--		PHYSICS tracks the current bird location, applies vertical boundaries to its
--		movement (to prevent the bird from moving out of the screen), and applies
--		physics (impulse updwards on lclick, otherwise falling downwards).
--
--		The physics calculations are frame dependent. By default they are locked to
--		60Hz (vert_sync).
--
--		The bird moves v rows each frame. The velocity (v) decrements to GRAVITY over
--		time, creating the traditional bouncy, floaty movement when the bird reaches
--		the apex of each jump.



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY physics IS
	PORT (
		clk_25k, vert_sync	: IN std_logic;	
		reset, enable		: IN std_logic;	
		mouse_lclick			: IN std_logic;		
		y_pos 					: OUT std_logic_vector(9 downto 0)
	);
END ENTITY physics;

ARCHITECTURE a OF physics IS
CONSTANT GRAVITY			: SIGNED(9 downto 0)		:= TO_SIGNED(5,10);		-- rate of descent
CONSTANT DECEL				: SIGNED(9 downto 0)		:= TO_SIGNED(1,10);		-- rate of movement towards equillibrium (GRAVITY)
CONSTANT IMPULSE			: SIGNED(9 downto 0)		:= TO_SIGNED(-10,10);		-- rate of ascent

---- we could disable input for a short time after it is first received as mouse clicks are significantly longer than one 25Mhz clock cycle
---- at 60Hz clk for a 50ms delay the count would be 3
---- for reference, average human reaction time is 150-250ms

SIGNAL v						: SIGNED(9 downto 0);
SIGNAL y						: SIGNED(9 downto 0) 	:= TO_SIGNED(240,10);		-- start in middle of screen

BEGIN

	Click_Check: PROCESS(vert_sync, reset)
	BEGIN
		if (reset = '1') then
			v <= (others => '0');
		elsif (rising_edge(vert_sync)) then
			if (enable = '1') then
				if (mouse_lclick = '1') then
					v <= IMPULSE;		-- 0 is top; thus negative is up
				else
					if (v + DECEL >= GRAVITY) then
						v <= GRAVITY;		-- cap maximum descent rate
					else
						v <= v + DECEL;	-- 480 is bottom; thus positive is down
					end if;
				end if;
			end if;
		end if;
	END PROCESS Click_Check;
	
	Boundary_Check: PROCESS(vert_sync, reset)  	
	BEGIN
		if (reset = '1') then
			y <= TO_SIGNED(240,10);		-- start in middle of screen
		-- Move ball once every vertical sync
		elsif (rising_edge(vert_sync)) then		
			if (enable = '1') then
				-- Stop off top or bottom of the screen
				-- Note: Adding buffer of 6*8 to prevent sprite bounds overlap
				if ((y + v) >= TO_SIGNED(431,10)) then
					y <= TO_SIGNED(431,10);
				elsif ((y + v) <= TO_SIGNED(0,10)) then 
					y <= TO_SIGNED(0,10);
				else
					y <= y + v;
				end if;
				
				y_pos <= STD_LOGIC_VECTOR(y);
			end if;
		end if;
	END PROCESS Boundary_Check;
	

END a;



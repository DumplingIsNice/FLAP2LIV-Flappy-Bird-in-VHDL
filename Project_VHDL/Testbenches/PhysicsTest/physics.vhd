LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

ENTITY physics IS
	PORT
		(clk_25k, vert_sync, mouse_lclick : IN std_logic;		
		y_pos : OUT std_logic_vector(9 downto 0));
END ENTITY physics;

ARCHITECTURE a OF physics IS

CONSTANT GRAVITY			: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(32,10);		-- top to bottom of screen in 0.5s
CONSTANT IMPULSE			: STD_LOGIC_VECTOR(9 downto 0)	:= CONV_STD_LOGIC_VECTOR(128,10);	-- 
-- we must disable input for a short time after it is first received as mouse clicks are significantly longer than one 25Mhz clock cycle
-- at 60Hz clk for a 50ms delay the count would be 3
-- for reference, average human reaction time is 150-300ms

SIGNAL v						: std_logic_vector(1 downto 0);
SIGNAL y						: std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(240,10);		-- start in middle of screen

BEGIN

	v <= (v + IMPULSE) when (mouse_lclick = '1')
				else (v - GRAVITY);
	y <= y + v;	-- buffer as y_pos is OUT
	
	Boundary_Check: PROCESS(vert_sync)  	
	BEGIN
		-- Move ball once every vertical sync
		if (rising_edge(vert_sync)) then			
			-- Stop off top or bottom of the screen
			-- Note: Adding buffer of 8 to prevent sprite bounds overlap
			if ( ('0' & y >= CONV_STD_LOGIC_VECTOR(479,10) - CONV_STD_LOGIC_VECTOR(8,10)) ) then
				y <= CONV_STD_LOGIC_VECTOR(479,10);
			elsif (y <= CONV_STD_LOGIC_VECTOR(8,10)) then 
				y <= CONV_STD_LOGIC_VECTOR(0,10);
			end if;
			
			y_pos <= y;
		end if;
	END PROCESS Boundary_Check;
	

END a;



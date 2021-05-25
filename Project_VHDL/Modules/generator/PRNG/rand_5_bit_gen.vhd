-- This componet is a Pseudo Random Number Generator (PRNG) implemented as a Galois Linear Feedback Shift Register (LFSR)
-- Input:
    -- seed - A array of 5 10-bit non-zero value as the intial input value.
    -- gen - Control signal for shift register to shift right. Generates new output values.
    -- enable - When high, RNG commences.
    --        - When low, holds current output rand_out.
    -- reset - Asynchronous reset output to seed value.
-- Output: 
    -- rand_out - 5-bit output of values between (0-29)

-- Additonal Info:
--     Screen height of 480px. We want the gaps to be at least 40px away from the edge of the screen (at positions 0 and 479), 
--     so thus M the margin = 40px. Our gap height should be the size of flappy bird multiplied by 3 (subject to change). 
--     Thus if flappy bird is 32x32, then the gap height H is 96.

--     row > M        ->  row > 39
--     row < height - (M + H)  ->  row < 479 - (40 + 96) = 343
--     Range is 40->342, i.e. 302 individual pixels.

-- 	The value 302 would require a 9 bit unsigned value to store. To simplify, we could round the range to 300 (in doing so slightly increasing the lower padding by 2px), and then break it down into 10px chunks. The new value would have a maximum of 30, i.e. 5 bits to store.
-- 	We then fill a 5 bit std_logic_vector with random bits, constrain it to within the range 0 to 29 (rounding every 31 and 32 value to 29 creates a slight bias of 2/32 = ~6.3% towards the top, which we could ignore*), and multiply the final 5 bit value by 10 to recreate a signal with a range of 300 (just now with a resolution of 10, not 1).
-- 	This final value between 0->299 is then used to find the upper gap row bounds.

--    upper gap row = M + (0->299)
--    lower gap row = upper gap row + H = M + (0->299) + H

-- 	* (cropping the rng value to within the range 1->30 and then subtracting 1 would remove the bias but be more computationally intensive)

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

USE work.rand_num_pkg.all;

ENTITY rand_5_bit_gen IS
	PORT(   -- seed                    :   IN seed_pkg;
		    enable, gen, reset	    : 	IN STD_LOGIC;
		    rand_out                :	OUT STD_LOGIC_VECTOR (4 downto 0)
	    );
END rand_5_bit_gen;

ARCHITECTURE beh OF rand_5_bit_gen IS
	SIGNAL seed	: seed_pkg			:= FIXED_SEED;
	
    COMPONENT psudo_rand_gen IS
    PORT(   seed	                :	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    		enable, gen, reset	    : 	IN STD_LOGIC;
    		q                       :	OUT STD_LOGIC
    	);
    END COMPONENT psudo_rand_gen;

    SIGNAL q_r0, q_r1, q_r2, q_r3, q_r4 : STD_LOGIC;
    SIGNAL rand_out_i : STD_LOGIC_VECTOR (4 downto 0);
BEGIN

    -- Each component in parallel outputs its feedback bit.
    R0: psudo_rand_gen port map (   seed => seed(0),
                                    enable => enable,
                                    gen => gen,
                                    reset => reset,
                                    q => q_r0
                                );
    R1: psudo_rand_gen port map (   seed => seed(1),
                                    enable => enable,
                                    gen => gen,
                                    reset => reset,
                                    q => q_r1
                                );
    R2: psudo_rand_gen port map (   seed => seed(2),
                                    enable => enable,
                                    gen => gen,
                                    reset => reset,
                                    q => q_r2
                                );
    R3: psudo_rand_gen port map (   seed => seed(3),
                                    enable => enable,
                                    gen => gen,
                                    reset => reset,
                                    q => q_r3
                                );
    R4: psudo_rand_gen port map (   seed => seed(4),
                                    enable => enable,
                                    gen => gen,
                                    reset => reset,
                                    q => q_r4
                                );               

    seed(0) <= "0000000000";
    seed(1) <= "1001000001";
    seed(2) <= "1001000010";
    seed(3) <= "1001000100";
    seed(4) <= "1001001000";
    -- Feedback bits concat to 5-bit value, (0-31).
    rand_out_i <= q_r4&q_r3&q_r2&q_r1&q_r0;
    
    PROCESS (rand_out_i) IS
    BEGIN
        -- Noticable trend of commonity of 0s, and 1s. Made bias to center of screen.
        IF (CONV_INTEGER(rand_out_i) = 31) THEN
            rand_out <= CONV_STD_LOGIC_VECTOR(16, rand_out_i'length);
        ELSIF (CONV_INTEGER(rand_out_i) = 30) THEN
            rand_out <= CONV_STD_LOGIC_VECTOR(15, rand_out_i'length);
        ELSE
            rand_out <= rand_out_i;
        END IF;
    END PROCESS;

END beh; 
-- This componet is a Pseudo Random Number Generator (PRNG) implemented as a Galois Linear Feedback Shift Register (LFSR)
-- Input:
    -- seed - A non-zero value as the intial input value.
    -- enable - When high, RNG commences.
    --        - When low, holds current output q.
    -- reset - Synchronous reset to seed value.
-- Output: 
    -- q - Currently the full 10-bit shift register for debugging purposes.
    --     Must uses the (0) feedback value as the most random output.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY psudo_rand_gen IS
	PORT(   seed	                :	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    enable, clock, reset	: 	IN STD_LOGIC;
		    q                       :	OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	    );
END psudo_rand_gen;

ARCHITECTURE beh OF psudo_rand_gen IS
    SIGNAL q_i : STD_LOGIC_VECTOR (9 DOWNTO 0);
BEGIN

    q <= q_i;

    shift: PROCESS (clock, reset) is
        VARIABLE temp_tap1 : STD_LOGIC;
    BEGIN
        IF (RISING_EDGE(CLOCK) AND (enable = '1')) THEN
            IF (reset = '1') THEN
                q_i <= seed;
            ELSE
            -- 10bit right shift register, tap[7, 0]=tapmask=0010000001, with 1023 Cycle period.
                q_i(9) <= q_i(0);
                temp_tap1 := q_i(7) xor q_i(0);

                q_i(8 downto 0) <= q_i(9 downto 1);
                q_i(6) <= temp_tap1;
            END IF;

            -- Zero value protection
            IF (q_i = CONV_STD_LOGIC_VECTOR(0, q_i'length)) THEN
                q_i <= seed;
            END IF;            
        END IF;
    END PROCESS;

END beh; 
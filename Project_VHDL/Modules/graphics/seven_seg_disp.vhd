LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
-- USE IEEE.STD_LOGIC_ARITH.all;
-- USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.all;

ENTITY seven_segment_disp IS
    PORT (  clk         : IN STD_LOGIC;
            in_value    : IN UNSIGNED (7 downto 0);
            LED_out     : OUT STD_LOGIC_VECTOR (6 downto 0);
            digit       : OUT UNSIGNED (3 downto 0) := "0000"
        );
END ENTITY seven_segment_disp;

ARCHITECTURE beh OF SEVEN_SEGMENT_DISP IS
    CONSTANT HUN_CONST : UNSIGNED (14 downto 0) := to_unsigned(327, 15); -- 2^15/100
    CONSTANT TEN_CONST : UNSIGNED (14 downto 0) := to_unsigned(3276,15); -- 2^15/10
    SIGNAL digit_hun, digit_ten, digit_one  : UNSIGNED (3 downto 0);
BEGIN
    deCypherInput: PROCESS(clk, in_value)
        VARIABLE intermediate               : UNSIGNED (7 downto 0);
        VARIABLE multi_i100, multi_i10      : UNSIGNED (22 downto 0);
        VARIABLE digit_h, digit_t, digit_o  : UNSIGNED (3 downto 0);
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            -- Constant division algorithm
            -- (dividend*(2^(quantize-bits - 1)/CONSTANT)) >> 15 = divident/CONSTANT
            -- With 2^11 rounding.
            multi_i100 := SHIFT_RIGHT(in_value * HUN_CONST + (2**11), 15);
            multi_i10  := SHIFT_RIGHT(in_value * TEN_CONST + (2**11), 15);
            
            digit_h := multi_i100 (3 downto 0);

            intermediate := (to_unsigned(10, 4) * digit_h);
            digit_t := multi_i10 (3 downto 0) - intermediate(3 downto 0);

            intermediate := (digit_h*to_unsigned(100, 4) + digit_t*to_unsigned(10, 4));
            intermediate := in_value - intermediate;

            -- Rounding correction at 10th digits.
            IF intermediate(3 downto 0) > 9 THEN
                digit_o := to_unsigned(0, 4);
            ELSE
                digit_o := intermediate(3 downto 0);
            END IF;

            digit_hun <= digit_h;
            digit_ten <= digit_t;
            digit_one <= digit_o;
        END IF;
    END PROCESS;
END beh;
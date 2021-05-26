LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
-- USE IEEE.STD_LOGIC_ARITH.all;
-- USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.all;

ENTITY seven_segment_disp IS
    PORT (  clk, all_off                                : IN STD_LOGIC;
            in_value                                    : IN UNSIGNED (7 downto 0);
            LED_out_ones, LED_out_tens, LED_out_huns    : OUT STD_LOGIC_VECTOR (7 downto 0)
        );
END ENTITY seven_segment_disp;

ARCHITECTURE beh OF SEVEN_SEGMENT_DISP IS
    CONSTANT HUN_CONST                              : UNSIGNED (14 downto 0) := to_unsigned(327, 15); -- 2^15/100
    CONSTANT TEN_CONST                              : UNSIGNED (14 downto 0) := to_unsigned(3276,15); -- 2^15/10
    SIGNAL digit_huns, digit_tens, digit_ones       : STD_LOGIC_VECTOR (3 downto 0);
    SIGNAL LED_dp_huns, LED_dp_tens, LED_dp_ones    : std_logic;  

    COMPONENT seven_seg_converter IS
        PORT (Data_In : IN STD_LOGIC_VECTOR (3 downto 0);
              DP_In : IN STD_LOGIC;
              Data_Out : OUT STD_LOGIC_VECTOR (7 downto 0));
    END COMPONENT seven_seg_converter;
BEGIN
    converterOnes: seven_seg_converter port map (   Data_In     =>  digit_ones,
                                                    DP_In       =>  LED_dp_ones,
                                                    Data_Out    =>  LED_out_ones
                                                );
    converterTens: seven_seg_converter port map (   Data_In     =>  digit_tens,
                                                    DP_In       =>  LED_dp_tens,
                                                    Data_Out    =>  LED_out_tens
                                                );
    converterHuns: seven_seg_converter port map (   Data_In     =>  digit_huns,
                                                    DP_In       =>  LED_dp_huns,
                                                    Data_Out    =>  LED_out_huns
                                                );

    deCypherInput: PROCESS(clk, in_value, all_off)
        VARIABLE intermediate               : UNSIGNED (7 downto 0);
        VARIABLE multi_i100, multi_i10      : UNSIGNED (22 downto 0);
        VARIABLE digit_h, digit_t, digit_o  : UNSIGNED (3 downto 0);
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            IF (all_off = '1') THEN
                digit_ones <= "1111";
                digit_tens <= "1111";
                digit_huns <= "1111";
            ELSE
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

                digit_huns <= STD_LOGIC_VECTOR(digit_h);
                digit_tens <= STD_LOGIC_VECTOR(digit_t);
                digit_ones <= STD_LOGIC_VECTOR(digit_o);
            END IF;
        END IF;
    END PROCESS;

    LED_dp_ones <= '1';
    LED_dp_tens <= '1';
    LED_dp_huns <= '1';
END beh;
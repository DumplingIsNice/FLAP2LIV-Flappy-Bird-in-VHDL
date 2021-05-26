LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
-- USE IEEE.STD_LOGIC_ARITH.all;
-- USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.all;

ENTITY seven_segment_disp IS
    PORT (  clk, all_off                                : IN STD_LOGIC;
            in_value                                    : IN UNSIGNED (7 downto 0);
            LED_out_ones, LED_out_tens, LED_out_huns    : OUT STD_LOGIC_VECTOR (6 downto 0);
            digit                                       : OUT UNSIGNED (3 downto 0) := "0000"
        );
END ENTITY seven_segment_disp;

ARCHITECTURE beh OF SEVEN_SEGMENT_DISP IS
    CONSTANT HUN_CONST : UNSIGNED (14 downto 0) := to_unsigned(327, 15); -- 2^15/100
    CONSTANT TEN_CONST : UNSIGNED (14 downto 0) := to_unsigned(3276,15); -- 2^15/10
    SIGNAL digit_huns, digit_tens, digit_ones  : UNSIGNED (3 downto 0);
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

            digit_huns <= digit_h;
            digit_tens <= digit_t;
            digit_ones <= digit_o;
        END IF;
    END PROCESS;

    -- Cathode patterns of the 7-segment LED display 
    Sev_seg_assign1: PROCESS(digit_ones, all_off)
    BEGIN
        IF (all_off = '1') THEN
            LED_out_ones <= "1111111";
        ELSE
            CASE digit_ones IS
                WHEN "0000" => LED_out_ones <= "0000001"; -- "0"     
                WHEN "0001" => LED_out_ones <= "1001111"; -- "1" 
                WHEN "0010" => LED_out_ones <= "0010010"; -- "2" 
                WHEN "0011" => LED_out_ones <= "0000110"; -- "3" 
                WHEN "0100" => LED_out_ones <= "1001100"; -- "4" 
                WHEN "0101" => LED_out_ones <= "0100100"; -- "5" 
                WHEN "0110" => LED_out_ones <= "0100000"; -- "6" 
                WHEN "0111" => LED_out_ones <= "0001111"; -- "7" 
                WHEN "1000" => LED_out_ones <= "0000000"; -- "8"     
                WHEN "1001" => LED_out_ones <= "0000100"; -- "9"
                WHEN OTHERS  => NULL; 
            END CASE;
        END IF;
    END PROCESS;

    -- Cathode patterns of the 7-segment LED display 
    Sev_seg_assign10: PROCESS(digit_tens, all_off)
    BEGIN
        IF (all_off = '1') THEN
            LED_out_tens <= "1111111";
        ELSE
            CASE digit_tens IS
                WHEN "0000" => LED_out_tens <= "0000001"; -- "0"     
                WHEN "0001" => LED_out_tens <= "1001111"; -- "1" 
                WHEN "0010" => LED_out_tens <= "0010010"; -- "2" 
                WHEN "0011" => LED_out_tens <= "0000110"; -- "3" 
                WHEN "0100" => LED_out_tens <= "1001100"; -- "4" 
                WHEN "0101" => LED_out_tens <= "0100100"; -- "5" 
                WHEN "0110" => LED_out_tens <= "0100000"; -- "6" 
                WHEN "0111" => LED_out_tens <= "0001111"; -- "7" 
                WHEN "1000" => LED_out_tens <= "0000000"; -- "8"     
                WHEN "1001" => LED_out_tens <= "0000100"; -- "9" 
                WHEN OTHERS  => NULL;
            END CASE;
        END IF;
    END PROCESS;

    -- Cathode patterns of the 7-segment LED display 
    Sev_seg_assign100: PROCESS(digit_huns, all_off)
    BEGIN
        IF (all_off = '1') THEN
            LED_out_huns <= "1111111";
        ELSE
            CASE digit_huns IS
                WHEN "0000" => LED_out_huns <= "0000001"; -- "0"     
                WHEN "0001" => LED_out_huns <= "1001111"; -- "1" 
                WHEN "0010" => LED_out_huns <= "0010010"; -- "2" 
                WHEN "0011" => LED_out_huns <= "0000110"; -- "3" 
                WHEN "0100" => LED_out_huns <= "1001100"; -- "4" 
                WHEN "0101" => LED_out_huns <= "0100100"; -- "5" 
                WHEN "0110" => LED_out_huns <= "0100000"; -- "6" 
                WHEN "0111" => LED_out_huns <= "0001111"; -- "7" 
                WHEN "1000" => LED_out_huns <= "0000000"; -- "8"     
                WHEN "1001" => LED_out_huns <= "0000100"; -- "9" 
                WHEN OTHERS  => NULL;
            END CASE;
        END IF;
    END PROCESS;
END beh;
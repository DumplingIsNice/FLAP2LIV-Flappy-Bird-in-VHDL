-- This package defines helpful funtions, types and constancts regarding to random numbers

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

PACKAGE rand_num_pkg IS 
    TYPE seed_pkg IS ARRAY(4 downto 0) of STD_LOGIC_VECTOR (9 downto 0);

    CONSTANT FIXED_SEED : seed_pkg := (others => "1001000000");
END PACKAGE rand_num_pkg;
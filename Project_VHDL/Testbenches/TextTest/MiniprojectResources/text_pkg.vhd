-- This package defines helpful funtions, types and constancts regarding to text display
-- As of (08/05,2021), this package also includes the definitions of the characters 
-- to be displayed on the screen.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

PACKAGE text_pkg IS 

TYPE FONT_CHAR IS RECORD
    x, y        : STD_LOGIC_VECTOR(9 DOWNTO 0);
    scale       : STD_LOGIC_VECTOR(2 DOWNTO 0);
    address     : STD_LOGIC_VECTOR (5 DOWNTO 0);
END RECORD;

-- All font addresses in octaves
CONSTANT FONT_A : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"01";
CONSTANT FONT_B : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"02";
CONSTANT FONT_C : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"03";
CONSTANT FONT_D : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"04";
CONSTANT FONT_E : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"05";
CONSTANT FONT_F : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"06";
CONSTANT FONT_G : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"07";
CONSTANT FONT_H : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"10";
CONSTANT FONT_I : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"11";
CONSTANT FONT_J : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"12";
CONSTANT FONT_K : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"13";
CONSTANT FONT_L : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"14";
CONSTANT FONT_M : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"15";
CONSTANT FONT_N : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"16";
CONSTANT FONT_O : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"17";
CONSTANT FONT_P : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"20";
CONSTANT FONT_Q : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"21";
CONSTANT FONT_R : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"22";
CONSTANT FONT_S : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"23";
CONSTANT FONT_T : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"24";
CONSTANT FONT_U : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"25";
CONSTANT FONT_V : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"26";
CONSTANT FONT_W : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"27";
CONSTANT FONT_X : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"30";
CONSTANT FONT_Y : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"31";
CONSTANT FONT_Z : STD_LOGIC_VECTOR (5 DOWNTO 0) := o"32";

CONSTANT CHAR_A : FONT_CHAR :=   
                            (   
                                x => conv_std_logic_vector(100, 10),
                                y => conv_std_logic_vector(50, 10),
                                scale => conv_std_logic_vector(1, 3),
                                address => FONT_Z
                            );

END PACKAGE text_pkg;

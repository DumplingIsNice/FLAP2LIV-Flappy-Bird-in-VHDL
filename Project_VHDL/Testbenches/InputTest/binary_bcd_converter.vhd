library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
use  IEEE.numeric_std.all;

ENTITY binary_bcd_converter IS
PORT(
	 binary_num 										: IN UNSIGNED(9 downto 0);
	 bcd_ones, bcd_tens, bcd_hundreds 			: OUT UNSIGNED(3 downto 0));
END ENTITY binary_bcd_converter;


ARCHITECTURE behaviour OF binary_bcd_converter IS
SIGNAL ones, tens, hundreds		:	UNSIGNED(9 downto 0);
BEGIN	

calculate: PROCESS(binary_num)
BEGIN
	ones <= (binary_num) mod TO_UNSIGNED(10,10);
	tens <= ((binary_num) / TO_UNSIGNED(10,10)) mod TO_UNSIGNED(10,10);
	hundreds <= (binary_num) / TO_UNSIGNED(100,10);
END PROCESS calculate;

bcd_ones <= ones(3 downto 0);
bcd_tens <= tens(3 downto 0);
bcd_hundreds <= hundreds(3 downto 0);

END ARCHITECTURE behaviour;
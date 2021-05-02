-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
-- CREATED		"Sun May 02 20:20:15 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY physics_test_schematic_vhd IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		pb1 :  IN  STD_LOGIC;
		pb2 :  IN  STD_LOGIC;
		red_out :  OUT  STD_LOGIC;
		green_out :  OUT  STD_LOGIC;
		blue_out :  OUT  STD_LOGIC;
		horiz_sync_out :  OUT  STD_LOGIC;
		vert_sync_out :  OUT  STD_LOGIC
	);
END physics_test_schematic_vhd;

ARCHITECTURE bdf_type OF physics_test_schematic IS 

COMPONENT altpll0
	PORT(inclk0 : IN STD_LOGIC;
		 areset : IN STD_LOGIC;
		 c0 : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT vga_sync_original
	PORT(clock_25Mhz : IN STD_LOGIC;
		 red : IN STD_LOGIC;
		 green : IN STD_LOGIC;
		 blue : IN STD_LOGIC;
		 red_out : OUT STD_LOGIC;
		 green_out : OUT STD_LOGIC;
		 blue_out : OUT STD_LOGIC;
		 horiz_sync_out : OUT STD_LOGIC;
		 vert_sync_out : OUT STD_LOGIC;
		 pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 pixel_row : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;

COMPONENT bouncy_ball
	PORT(pb1 : IN STD_LOGIC;
		 pb2 : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 vert_sync : IN STD_LOGIC;
		 pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 pixel_row : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 red : OUT STD_LOGIC;
		 green : OUT STD_LOGIC;
		 blue : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(9 DOWNTO 0);


BEGIN 
vert_sync_out <= SYNTHESIZED_WIRE_5;
SYNTHESIZED_WIRE_0 <= '0';



b2v_inst : altpll0
PORT MAP(inclk0 => clk,
		 areset => SYNTHESIZED_WIRE_0,
		 c0 => SYNTHESIZED_WIRE_1);


b2v_inst1 : vga_sync_original
PORT MAP(clock_25Mhz => SYNTHESIZED_WIRE_1,
		 red => SYNTHESIZED_WIRE_2,
		 green => SYNTHESIZED_WIRE_3,
		 blue => SYNTHESIZED_WIRE_4,
		 red_out => red_out,
		 green_out => green_out,
		 blue_out => blue_out,
		 horiz_sync_out => horiz_sync_out,
		 vert_sync_out => SYNTHESIZED_WIRE_5,
		 pixel_column => SYNTHESIZED_WIRE_6,
		 pixel_row => SYNTHESIZED_WIRE_7);


b2v_inst3 : bouncy_ball
PORT MAP(pb1 => pb1,
		 pb2 => pb2,
		 clk => clk,
		 vert_sync => SYNTHESIZED_WIRE_5,
		 pixel_column => SYNTHESIZED_WIRE_6,
		 pixel_row => SYNTHESIZED_WIRE_7,
		 red => SYNTHESIZED_WIRE_2,
		 green => SYNTHESIZED_WIRE_3,
		 blue => SYNTHESIZED_WIRE_4);



END bdf_type;
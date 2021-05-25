-- GENERATOR_BUFFER

-- Single port, as used as component within GENERATOR_II


LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;

ENTITY generator_buffer IS
	PORT (
		clk, wrenable							: IN STD_LOGIC;
		address									: IN 
		data										: IN
		
		q											: OUT
		
		--clk
		--data[]
		--wraddress
		--wrenable
		
		--qout
	
	);
END ENTITY generator_buffer;


ARCHITECTURE behaviour OF generator_buffer IS
BEGIN

END behaviour;




-- Needed memory:


		obj_cols_left, obj_cols_right		: OUT OBJ_COLS;		-- array length 24, depth mixed
		obj_rows_upper, obj_rows_lower	: OUT OBJ_ROWS;
		obj_types								: OUT OBJ_TYPES;
		obj_red, obj_green, obj_blue		: OUT OBJ_COLOURS;



		
		
		

-- VHDL Example
-- This example shows how to create a 32x8 (32 words
-- 8 bits per word) synchronous, dual-port RAM
--
--library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
--
--ENTITY ram_32x8d_infer IS GENERIC
--	d_width			: INTEGER	:= 8;
--	addr_width		: INTEGER	:= 5;
--	mem_depth		: INTEGER	:= 32;
--	PORT (
--		clk, wren	: IN STD_LOGIC;
--		data			: IN STD_LOGIC_VECTOR(d_width - 1 downto 0);
--		raddr			: IN STD_LOGIC_VECTOR(addr_width - 1 downto 0));
--		waddr			: IN STD_LOGIC_VECTOR(addr_width - 1 downto 0));
--		
--		output		: OUT STD_LOGIC_VECTOR(d_width - 1 downto 0);	
--	);
--END ENTITY ram_32x8d_infer;
--
--architecture xilinx of ram_32x8d_infer is
--type mem_type is array (mem_depth - 1 downto 0) of
--STD_LOGIC_VECTOR (d_width - 1 downto 0);
--
--signal mem : mem_type;
--
--begin
--
--process(clk, we, waddr)
--begin
--if (rising_edge(clk)) then
--if (we = '1') then
--mem(conv_integer(waddr)) <= d;
--end if;
--end if;
--end process;
--
--process(raddr)
--begin
--o <= mem(conv_integer(raddr));
--end process;
--
--end xilinx;
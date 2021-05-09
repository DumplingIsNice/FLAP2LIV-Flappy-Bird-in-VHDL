library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.all;

entity test_text_datapath is
end entity test_text_datapath;

architecture my_test of test_text_datapath is
    signal  t_row, t_col	        : STD_LOGIC_VECTOR(9 DOWNTO 0);
	signal  t_clock				    : STD_LOGIC;
	signal	t_font_row, t_font_col  : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal  t_scale                 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal  t_o_address             : STD_LOGIC_VECTOR (5 DOWNTO 0);
    
    component text_datapath IS
	PORT(   row, col	        : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            clock				: IN STD_LOGIC;
            font_row, font_col  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            scale               : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            o_address           : OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
        );
    end component text_datapath;
    
begin
    DUT: text_datapath port map (row => t_row, 
                                clock => t_clock,
                                col => t_col, 
                                font_col => t_font_col,
                                font_row => t_font_row,
                                scale => t_scale,
                                o_address => t_o_address);
    -- setialization process (code that executes only once).

-- clock generation
    clock_gen: process
    begin
        t_clock <= '0';
        wait for 5 ns;
        t_clock <= '1';
        wait for 5 ns;
    end process clock_gen;

-- row, col generation
-- The font fow and column refers to the row and column of the pixel position 
-- returned from the window from VGC_sync
-- Check character's position definition in text_pkg.vhd
    row_col_gen: process
    begin
        t_row <= conv_std_logic_vector(0, t_row'length);
        t_col <= conv_std_logic_vector(0, t_col'length);
        wait for 50 ns;
        t_row <= conv_std_logic_vector(50, t_row'length);
        t_col <= conv_std_logic_vector(100, t_col'length);
        wait for 50 ns;

        -- Test case for col/x position
        for i in 1 to 8 loop
            t_col <= conv_std_logic_vector((unsigned(t_col) + 1), t_col'length);
            wait for 10 ns;
        end loop;

        wait for 50 ns;
        t_row <= conv_std_logic_vector(50, t_row'length);
        t_col <= conv_std_logic_vector(100, t_col'length);
        wait for 50 ns;

        -- Test case for row/y position
        for i in 1 to 8 loop
            t_row <= conv_std_logic_vector((unsigned(t_row) + 1), t_row'length);
            wait for 10 ns;
        end loop;

        -- Test case for col/x and row/y position
        wait for 50 ns;
        t_row <= conv_std_logic_vector(58, t_row'length);
        t_col <= conv_std_logic_vector(108, t_col'length);
        wait for 50 ns;
    end process row_col_gen;
    
end architecture my_test;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity test_char_rom is
end entity test_char_rom;

architecture my_test of test_char_rom is
    signal t_character_address	    :STD_LOGIC_VECTOR (5 DOWNTO 0);
    signal t_font_row, t_font_col	:STD_LOGIC_VECTOR (2 DOWNTO 0);
    signal t_clock				    :STD_LOGIC ;
    signal t_rom_mux_output	        :STD_LOGIC;
    
    component char_rom IS
	PORT(   character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            clock				: 	IN STD_LOGIC ;
            rom_mux_output		:	OUT STD_LOGIC);
    end component char_rom;
    
begin
    DUT: char_rom port map (character_address => t_character_address, 
                            font_row => t_font_row,
                            font_col => t_font_col,
                            clock => t_clock,
                            rom_mux_output => t_rom_mux_output);
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
-- The font fow and column refers to the row and column of the font's 
-- indivisual pixel data selected in the rom.
-- Currently views the top row of 'A'
    row_col_gen: process
        variable value : unsigned (2 DOWNTO 0) := "000";
    begin
        t_font_row <= "000"; -- t_font_col <= "000";
        wait for 20 ns;
        t_font_col <= std_logic_vector(unsigned(value) + 1);
        value := value + 1;
        if (value = "111") then
            value := "000";
        end if;
        wait for 20 ns;
    end process row_col_gen;

-- address generation
-- Each address referes to a font
add_gen: process
begin
    t_character_address <= "000001";
    wait;
end process add_gen;
    
end architecture my_test;
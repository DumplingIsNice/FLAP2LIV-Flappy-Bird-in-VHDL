
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity seven_segment_disp_tb is
end entity;

architecture bench of seven_segment_disp_tb is

  component seven_segment_disp
      PORT (  clk         : IN STD_LOGIC;
              in_value    : IN UNSIGNED (7 downto 0);
              LED_out     : OUT STD_LOGIC_VECTOR (6 downto 0);
              digit       : OUT UNSIGNED (3 downto 0)
          );
  end component;

  signal clk: STD_LOGIC;
  signal in_value: UNSIGNED (7 downto 0);
  signal LED_out: STD_LOGIC_VECTOR (6 downto 0);
  signal digit: UNSIGNED (3 downto 0);

begin

  uut: seven_segment_disp port map ( clk      => clk,
                                     in_value => in_value,
                                     LED_out  => LED_out,
                                     digit    => digit );

    clk_gen: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process clk_gen;

    stimulus: process
    begin
        for i in 255 downto 0 LOOP
            in_value <= to_unsigned(i, 8);
            wait for 10 ns;
        END LOOP;
        
    end process;


end;
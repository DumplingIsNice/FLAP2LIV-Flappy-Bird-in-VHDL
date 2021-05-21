library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.all;

entity test_psudo_rand_gen is
end entity test_psudo_rand_gen;

architecture my_test of test_psudo_rand_gen is
    SIGNAL  t_seed	                    :	STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL	t_enable, t_clock, t_reset	: 	STD_LOGIC;
	SIGNAL	t_q                         :	STD_LOGIC_VECTOR (9 DOWNTO 0);
    
    component psudo_rand_gen IS
    PORT(   seed	                :	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    		enable, clock, reset	: 	IN STD_LOGIC;
    		q                       :	OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
    	);
    END component psudo_rand_gen;
    
begin
    DUT: psudo_rand_gen port map(   seed => t_seed,
                                    enable => t_enable,
                                    clock => t_clock,
                                    reset => t_reset,
                                    q => t_q
                                );
    -- setialization process (code that executes only once).

-- clock generation
    clock_gen: process
    begin
        t_clock <= '0';
        wait for 5 ns;
        t_clock <= '1';
        wait for 5 ns;
    end process clock_gen;

    ctrl_gen: process
    begin
        t_enable <= '1';
        t_reset <='1';
        t_seed <= "1001000000";
        wait for 10 ns;
        t_reset <='0';
        wait;
    end process;
    
end architecture my_test;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.all;

entity test_psudo_rand_gen is
end entity test_psudo_rand_gen;

architecture my_test of test_psudo_rand_gen is
    SIGNAL  t_seed	                    :	STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL	t_enable, t_gen, t_reset	: 	STD_LOGIC;
	SIGNAL	t_q                         :	STD_LOGIC;
    
    component psudo_rand_gen IS
    PORT(   seed	                :	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    		enable, gen, reset	: 	IN STD_LOGIC;
    		q                       :	OUT STD_LOGIC
    	);
    END component psudo_rand_gen;
    
begin
    DUT: psudo_rand_gen port map(   seed => t_seed,
                                    enable => t_enable,
                                    gen => t_gen,
                                    reset => t_reset,
                                    q => t_q
                                );
    -- setialization process (code that executes only once).

-- generation
    gen: process
    begin
        t_gen <= '0';
        wait for 5 ns;
        t_gen <= '1';
        wait for 5 ns;
    end process gen;

    ctrl_gen: process
    begin
        t_enable <= '1';
        t_reset <='0';
        t_seed <= "1001000000";
        wait for 100 ns;
        -- t_reset <='1', '0' after 10 ns;

        t_enable <= '0', '1' after 100 ns, '0' after 200 ns, '1' after 300 ns;
        t_reset <='1', '0' after 10 ns;
        wait;
    end process;
    
end architecture my_test;
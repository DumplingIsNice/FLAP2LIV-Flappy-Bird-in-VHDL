library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE work.rand_num_pkg.all;

entity test_rand_5_bit_gen is
end entity test_rand_5_bit_gen;

architecture my_test of test_rand_5_bit_gen is
    SIGNAL  t_seed	                        :	seed_pkg;
	SIGNAL	t_enable, t_gen, t_reset	    : 	STD_LOGIC;
	SIGNAL	t_out                           :	STD_LOGIC_VECTOR (4 DOWNTO 0);
    
    COMPONENT rand_5_bit_gen IS
	PORT(   seed                    :   IN seed_pkg;
		    enable, gen, reset	    : 	IN STD_LOGIC;
		    rand_out                 :	OUT STD_LOGIC_VECTOR (4 downto 0)
	    );
    END COMPONENT rand_5_bit_gen;
begin
    DUT: rand_5_bit_gen port map(   seed => t_seed,
                                    enable => t_enable,
                                    gen => t_gen,
                                    reset => t_reset,
                                    rand_out => t_out
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
        wait for 100 ns;
        t_enable <= '0', '1' after 100 ns, '0' after 200 ns, '1' after 300 ns;
        t_reset <= '1' after 10 ns, '0' after 20 ns;
        wait;
    end process;

    seed_gen: process
    begin        
        t_seed(0) <= "0000000000";
        t_seed(1) <= "1001000001";
        t_seed(2) <= "1001000010";
        t_seed(3) <= "1001000100";
        t_seed(4) <= "1001001000";
        wait;
    end process;
    
end architecture my_test;
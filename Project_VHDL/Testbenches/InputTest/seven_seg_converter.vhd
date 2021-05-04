library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;


entity seven_seg_converter is
  port (Data_In : in std_logic_vector (3 downto 0);
        DP_In : in std_logic;
        Data_Out : out std_logic_vector (7 downto 0));
end entity seven_seg_converter;


architecture behaviour of seven_seg_converter is
  begin
    
    convert: process(Data_In, DP_In)
    begin
      case Data_In is
        when "0001" =>  Data_Out(7 downto 1) <= "1001111";
        when "0010" =>  Data_Out(7 downto 1) <= "0010010";
        when "0011" =>  Data_Out(7 downto 1) <= "0000110";
        when "0100" =>  Data_Out(7 downto 1) <= "1001100";
        when "0101" =>  Data_Out(7 downto 1) <= "0100100";
        when "0110" =>  Data_Out(7 downto 1) <= "0100000";
        when "0111" =>  Data_Out(7 downto 1) <= "0001111";
        when "1000" =>  Data_Out(7 downto 1) <= "0000000";
        when "1001" =>  Data_Out(7 downto 1) <= "0000100";
        when others =>  Data_Out(7 downto 1) <= "0000001";
      end case;
    
      Data_Out(0) <= DP_In;
    end process convert;
      
end architecture behaviour;
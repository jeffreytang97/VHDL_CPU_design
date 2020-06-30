library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity I_cache is
port(	
	-- Instruction address input 
	I_address_input : in std_logic_vector(4 downto 0);

	-- Instruction data output (op, rs, rt, rd, etc)
	I_data_output : out std_logic_vector(31 downto 0));

end I_cache;

architecture I_cache_arch of I_cache is
begin
	process(I_address_input)
	begin
		case I_address_input is
			when "00000" => 
				I_data_output <= "00100000000000010000000000000001"; --addi r1, r0,1
			when "00001" => 
				I_data_output <= "00100000000000100000000000000010"; --addi r2, r0,2
			when "00010" => 
				I_data_output <= "00000000010000010001000000100000"; --add r2,r2,r1
			when "00011" => 
				I_data_output <= "00001000000000000000000000000010"; --jump 00010
			when "00100" => 
				I_data_output <= "00000000000000000000000000000000"; --don't care
			when others => --nothing
		end case;
	end process;
end I_cache_arch;


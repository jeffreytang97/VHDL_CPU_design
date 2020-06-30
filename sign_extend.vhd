library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity sign_extend is
port(
	sign_extend_input : in std_logic_vector(15 downto 0);
	func : in std_logic_vector(1 downto 0);
	sign_extend_output : out std_logic_vector(31 downto 0));

end sign_extend;

architecture sign_extend_arch of sign_extend is
begin
	process(sign_extend_input, func)
	begin
		case func is
			when "00" => 
				sign_extend_output(31 downto 16) <= sign_extend_input;
				sign_extend_output(15 downto 0) <= (others => '0');
			when "01" => 
				sign_extend_output(31 downto 16) <= (others => sign_extend_input(15));
				sign_extend_output(15 downto 0) <= sign_extend_input;
			when "10" => 
				sign_extend_output(31 downto 16) <= (others => sign_extend_input(15));
				sign_extend_output(15 downto 0) <= sign_extend_input;
			when others => 
				sign_extend_output(31 downto 16) <= (others => '0');
				sign_extend_output(15 downto 0) <= sign_extend_input;
		end case;
	end process;
end sign_extend_arch;

library IEEE;
use IEEE.std_logic_1164.all;

entity PC is
port (input : in std_logic_vector (31 downto 0);
	reset : in std_logic;
	clk : in std_logic;
	output : out std_logic_vector (31 downto 0)
	);
end PC;

architecture arch_pc of PC is
begin
	process (clk, reset)
	begin
		if (reset = '1') then
			output <= (others => '0');
		elsif(clk'event and clk = '1') then
			output <= input;
		end if;
	end process;
end arch_PC;

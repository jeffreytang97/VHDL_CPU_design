library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity data_cache is
port(
	clk : in std_logic;
	reset : in std_logic;
	data_write : in std_logic;
	data_input : in std_logic_vector(31 downto 0);
	five_bit_address : in std_logic_vector(4 downto 0);       
	data_output : out std_logic_vector(31 downto 0));          

end data_cache;

architecture data_cache_arch of data_cache is

-- 32 line regFile because address is 5 bits (2^5 = 32 lines)
-- regFile to store data in memory (it acts as a RAM)

type data_memory is array(31 downto 0) of std_logic_vector(31 downto 0); 
signal registers : data_memory := (others => (others => '0'));

constant index_top : integer:= 31;
constant index_bottom : integer:= 0;

begin
	-- for load word instruction
	data_output <= registers(to_integer(unsigned(five_bit_address)));

	process(clk, reset, data_write)
	
	variable current_index: integer := 0;	
	begin
		if (reset = '1') then
			for i in index_bottom to index_top loop
				registers(i) <= (others => '0');
			end loop;
		elsif (clk'event and clk = '1') then
			if (data_write = '1') then
				current_index := to_integer(unsigned(five_bit_address));
				
				-- for store word instruction
				if ((index_bottom <= five_bit_address) and (index_top >= five_bit_address)) then
				registers(current_index) <= data_input;
				end if;
			end if;
		end if;
	end process;
end data_cache_arch;

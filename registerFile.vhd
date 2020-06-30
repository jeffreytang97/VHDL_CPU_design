
-- 32 x 32 register file
-- two read ports, one write port with write enable

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity regfile is
port( din : in std_logic_vector(31 downto 0);
	reset : in std_logic;
	clk : in std_logic;
	write : in std_logic;
	read_a : in std_logic_vector(4 downto 0);
	read_b : in std_logic_vector(4 downto 0);
	write_address : in std_logic_vector(4 downto 0);
	out_a : out std_logic_vector(31 downto 0);
	out_b : out std_logic_vector(31 downto 0));
end regfile ;

architecture arch_regfile of regfile is

	type registerFile is array(31 downto 0) of std_logic_vector(31 downto 0);
	signal registers : registerFile := (others => (others => '0'));
	constant index_top : integer:= 31;
	constant index_bottom : integer:= 0;

	begin

		-- output assignment done outside of the process because it is asynchronous (independent of the clk)

		out_a <= registers(to_integer(unsigned(read_a)));
		out_b <= registers(to_integer(unsigned(read_b)));

		process(clk, reset, registers)
	
		variable current_index: integer := 0;	
	                    
		begin              
			if (reset = '1') then
				for i in index_bottom to index_top loop
					registers(i) <= (others => '0');
				end loop;
			
			elsif (clk'event and clk = '1') then
				if (write = '1') then
					current_index := to_integer(unsigned(write_address));
					registers(current_index) <= din; -- write the input to the registers
				end if;
			end if;

		end process;
	
end arch_regfile;

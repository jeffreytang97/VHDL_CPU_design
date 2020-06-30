library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity alu is
port(x, y : in std_logic_vector(31 downto 0);
	-- two input operands
	add_sub : in std_logic ; -- 0 = add , 1 = sub
	logic_func : in std_logic_vector(1 downto 0 ); -- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
	func : in std_logic_vector(1 downto 0 ) ; -- 00 = lui, 01 = setless , 10 = arith , 11 = logic
	output : out std_logic_vector(31 downto 0);
	overflow : out std_logic;
	zero : out std_logic);
end alu;

architecture alu_arch of alu is

signal y_lui, add_sub_result, logic_result : std_logic_vector(31 downto 0);
signal slt_x_minus_y, MSB_of_adder_subtract : std_logic_vector(31 downto 0);
signal sign_bit : std_logic;

begin	
	
	process(add_sub, add_sub_result, logic_func, logic_result, func, y_lui, slt_x_minus_y, sign_bit, MSB_of_adder_subtract)
	begin
		y_lui <= y; --set the output y for the MUX at 00
	                       
		-- set less than 0 function
		slt_x_minus_y <= x - y;
		sign_bit <= slt_x_minus_y(31);
		
		MSB_of_adder_subtract(0) <= sign_bit; -- set the first digit to the sign bit, and this 32-bit 			value would either be 1 or 0.
		MSB_of_adder_subtract(31 downto 1) <= "0000000000000000000000000000000"; -- set all bit to 0

		-- add_sub operation
		if(add_sub = '0') then
			add_sub_result <= x + y;                   
		else
			add_sub_result <= x - y;
		end if;

	-- Check for zero
		if (add_sub_result = "00000000000000000000000000000000") then -- write in hexadecimal
			zero <= not '1'; -- to negate the output
		else 
			zero <= not '0'; -- to negate the output
		end if;
	
	-- Logical function
		if(logic_func = "00") then
			logic_result <= x AND y;
		elsif (logic_func = "01") then
			logic_result <= x OR y;
		elsif (logic_func = "10") then
			logic_result <= x XOR y;
		else
			logic_result <= x NOR y;
		end if;    
	
	-- MUX output implementation  
		if(func = "00") then
			output <= not y_lui;
		elsif (func = "01") then
			output <= not MSB_of_adder_subtract; 
		elsif (func = "10") then
			output <= not add_sub_result;
		else
			output <= not logic_result;
		end if;	
	end process;
	
	-- Overflow method
	overflow <= not '1' when (x(31) = '0' and y(31) = '0' and add_sub = '0' and add_sub_result(31) = '1') or
				(x(31) = '0' and y(31) = '1' and add_sub = '1' and add_sub_result(31) = '1') or
				(x(31) = '1' and y(31) = '1' and add_sub = '0' and add_sub_result(31) = '0') or
				(x(31) = '1' and y(31) = '0' and add_sub = '1' and add_sub_result(31) = '0') else
				not '0';
	
end alu_arch;
	
	
			
			

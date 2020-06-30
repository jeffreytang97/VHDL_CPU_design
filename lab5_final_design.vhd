library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.ALL;

entity  cpu  is
port(reset : in std_logic;
     clk   : in std_logic;
     rs_out, rt_out : out std_logic_vector(3 downto 0); -- output port_temps from reg. file
     pc_out : out std_logic_vector(3 downto 0);
     overflow, zero : out std_logic); -- will not be constrained in Xilinx since not enough LEDs
end cpu;

architecture struct_beh of cpu is

component cpu_datapath is --from lab4 cpu_datapath entity
    port (
	reset : in std_logic;
	clk : in std_logic;		
	reg_write : in std_logic;
	reg_dst : in std_logic;
	add_sub : in std_logic;
	data_write : in std_logic;
	alu_src : in std_logic;
	reg_src : in std_logic;
	pc_sel : in std_logic_vector(1 downto 0);
	branch_type : in std_logic_vector(1 downto 0);
	logic_func : in std_logic_vector(1 downto 0);
	func : in std_logic_vector(1 downto 0);
	zero : out std_logic;
	overflow : out std_logic;
	rt_output,rs_output, pc_output, instruction_cache_output : out std_logic_vector(31 downto 0));

end component;

-- table 1 and table 2 signal bits needed
signal reg_write : std_logic;
signal reg_dst : std_logic;
signal reg_in_src : std_logic;
signal alu_src : std_logic;
signal add_sub : std_logic;
signal data_write : std_logic;
signal logic_func : std_logic_vector(1 downto 0);
signal func : std_logic_vector(1 downto 0);
signal branch_type : std_logic_vector(1 downto 0);
signal pc_sel : std_logic_vector(1 downto 0);

-- signals needed for output and instruction break down
signal overflow_temp, zero_temp : std_logic;
signal rs_temp, rt_temp, pc_temp : std_logic_vector(31 downto 0);
signal instruction : std_logic_vector(31 downto 0);

--op code, func code and control signal
signal op_code : std_logic_vector(5 downto 0);
signal func_code : std_logic_vector(5 downto 0);
signal control_signal : std_logic_vector(13 downto 0);

begin
-- component instantiation
CPU_DATAPATH_X: cpu_datapath port map (reset, clk, reg_write, reg_dst, add_sub, data_write,
											alu_src, reg_in_src, pc_sel, branch_type, logic_func, func,
											zero_temp, overflow_temp, rt_temp, rs_temp, pc_temp, instruction);

	op_code <= instruction(31 downto 26); --op code is firs_tempt 6 bits of instruction
	func_code <= instruction(5 downto 0); --func code is last 6 bits of instruction

	
-- assigning the correct bit values to each control signal
reg_write <= control_signal(13);
reg_dst <= control_signal(12);
reg_in_src <= control_signal(11);
alu_src <= control_signal(10);
add_sub <= control_signal(9);
data_write <= control_signal(8);
logic_func <= control_signal(7 downto 6);
func <= control_signal(5 downto 4);
branch_type <= control_signal(3 downto 2);
pc_sel <= control_signal(1 downto 0);
	
-- assigning control signal appropriate bits depending on op code and func code
	process(op_code, func_code)
	begin
		case op_code is
		when "000000" => -- arithmetic
				case func_code is
					when "100000" => -- add
					control_signal <= "11100000100000";
					when "100010" => -- sub
					control_signal <= "11101000100000";
					when "101010" => -- slt
					control_signal <= "11101000010000";
					when "100100" => -- and
					control_signal <= "11101000110000";
					when "100101" => -- or
					control_signal <= "11101001110000";
					when "100110" => -- xor
					control_signal <= "11101010110000";
					when "100111" => -- nor
					control_signal <= "11101011110000";
					when "001000" => -- jr
					control_signal <= "00000000000010";
					when others => --shouldn't happen
				end case;
			when "001111" => -- lui
			control_signal <= "10110000000000";
			when "001000" => -- addi
			control_signal <= "10110000100000";
			when "001010" => -- slti
			control_signal <= "10111000010000";
			when "001100" => -- andi
			control_signal <= "10111000110000";
			when "001101" => -- ori
			control_signal <= "10111001110000";
			when "001110" => -- xori
			control_signal <= "10111010110000";
			when "100011" => -- lw
			control_signal <= "10010010100000";
			when "101011" => -- sw
			control_signal <= "00010100100000";
			when "000010" => -- j
			control_signal <= "00000000000001";
			when "000001" => -- bltz
			control_signal <= "00000000001100";
			when "000100" => -- beq
			control_signal <= "00000000000100";	
			when "000101" => -- bne
			control_signal <= "00000000001000";
			when others => --shouldn't happen	
		end case;
	end process;

	-- negate the outputs incase we need to show on board
	rs_out <= not(rs_temp(3 downto 0)); --show last 4 bits
	rt_out <= not(rt_temp(3 downto 0)); --show last 4 bits
	pc_out <= not(pc_temp(3 downto 0)); --show last 4 bits
	zero <= not(zero_temp);
	overflow <= not(overflow_temp);
end struct_beh;

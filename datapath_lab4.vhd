library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity cpu_datapath is
port(
	-- Control inputs
	clk, reset : in std_logic;
	pc_sel, branch_type : in std_logic_vector(1 downto 0); -- for next_address
	reg_write : in std_logic; -- for regFile
	data_write : in std_logic; -- for data cache
	logic_func, func : in std_logic_vector(1 downto 0); -- for ALU
	add_sub : in std_logic; -- for ALU
	reg_dst : in std_logic; -- rt or rd mux
	alu_src : in std_logic; -- for rt_out or sign_extend mux
	reg_in_src : in std_logic; -- to determine if it is a load write back or ALU op. (mux)
	
	-- outputs
	overflow : out std_logic;
	zero : out std_logic;
	rt_out, rs_out, i_cache_out, pc_out, d_cache_out, alu_out : out std_logic_vector(31 downto 0));
	
end cpu_datapath;

architecture arch_cpu_datapath of cpu_datapath is

-- PC component declaration
component PC
port(
	input : in std_logic_vector (31 downto 0);
	reset : in std_logic;
	clk : in std_logic;
	output : out std_logic_vector (31 downto 0));
end component;

-- next_address component declaration
component next_address
port(
	rt, rs : in std_logic_vector(31 downto 0); -- two register inputs
	pc : in std_logic_vector(31 downto 0);
	target_address : in std_logic_vector(25 downto 0);
	branch_type : in std_logic_vector(1 downto 0);
	pc_sel : in std_logic_vector(1 downto 0);
	next_pc : out std_logic_vector(31 downto 0));
end component;

-- instruction cache component declaration
component I_cache
port(
	I_address_input : in std_logic_vector(4 downto 0);
	I_data_output : out std_logic_vector(31 downto 0));
end component;

-- register file component declaration 
component regfile
port(
	din : in std_logic_vector(31 downto 0);
	reset : in std_logic;
	clk : in std_logic;
	write : in std_logic;
	read_a : in std_logic_vector(4 downto 0);
	read_b : in std_logic_vector(4 downto 0);
	write_address : in std_logic_vector(4 downto 0);
	out_a : out std_logic_vector(31 downto 0);
	out_b : out std_logic_vector(31 downto 0));
end component;

-- data memory component declaration
component data_cache
port(
	clk : in std_logic;
	reset : in std_logic;
	data_write : in std_logic;
	data_input : in std_logic_vector(31 downto 0);
	five_bit_address : in std_logic_vector(4 downto 0);       
	data_output : out std_logic_vector(31 downto 0));
end component;

-- ALU component declaration
component alu
port(
	x, y : in std_logic_vector(31 downto 0);
	-- two input operands
	add_sub : in std_logic ; -- 0 = add , 1 = sub
	logic_func : in std_logic_vector(1 downto 0 ); -- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
	func : in std_logic_vector(1 downto 0 ) ; -- 00 = lui, 01 = setless , 10 = arith , 11 = logic
	output : out std_logic_vector(31 downto 0);
	overflow : out std_logic;
	zero : out std_logic);
end component;

-- sign_extend component declaration
component sign_extend
port(
	sign_extend_input : in std_logic_vector(15 downto 0);
	func : in std_logic_vector(1 downto 0);
	sign_extend_output : out std_logic_vector(31 downto 0));
end component;


-- Signal declaration
-- PC
signal pc_output : std_logic_vector(31 downto 0);

-- Next-address
signal rs, rt, next_pc : std_logic_vector(31 downto 0);
signal target_address : std_logic_vector(25 downto 0);

-- instruction cache
signal i_cache_output : std_logic_vector(31 downto 0);
signal i_cache_address : std_logic_vector(4 downto 0);

-- regFile
signal read_a_rs_address, read_b_rt_address, write_address_reg : std_logic_vector(4 downto 0);
signal d_in : std_logic_vector(31 downto 0);

-- Data Cache
signal d_cache_output : std_logic_vector(31 downto 0);
signal d_cache_address : std_logic_vector(4 downto 0);

-- ALU
signal alu_output : std_logic_vector(31 downto 0);
signal y_in : std_logic_vector(31 downto 0);

-- Sign_extend
signal immediate_output : std_logic_vector(31 downto 0);
signal immediate_input : std_logic_vector(15 downto 0);

-- Configuration specification 
for PC_unit : PC use entity WORK.PC(arch_pc); 
for next_address_unit : next_address use entity WORK.next_address(arch_next_address); 
for I_cache_unit : I_cache use entity WORK.I_cache(I_cache_arch); 
for regfile_unit : regFile use entity WORK.regFile(arch_regfile); 
for data_cache_unit : data_cache use entity WORK.data_cache(data_cache_arch); 
for alu_unit : alu use entity WORK.alu(alu_arch); 
for sign_extend_unit : sign_extend use entity WORK.sign_extend(sign_extend_arch); 

begin
	-- Components instantiation
	PC_unit : PC port map(next_pc, reset, clk, pc_output);
	next_address_unit : next_address port map(rt, rs, pc_output, target_address, branch_type, pc_sel, next_pc);
	I_cache_unit : I_cache port map(i_cache_address, i_cache_output);
	regfile_unit : regfile port map(d_in, reset, clk, reg_write, read_a_rs_address, read_b_rt_address, write_address_reg, rs, rt);
	data_cache_unit : data_cache port map(clk, reset, data_write, rt, d_cache_address, d_cache_output);
	alu_unit : alu port map(rs, y_in, add_sub, logic_func, func, alu_output, overflow, zero);
	sign_extend_unit : sign_extend port map(immediate_input, func, immediate_output);


	-- Set the outputs to check functionality
	rt_out <= rt;
	rs_out <= rs;
	i_cache_out <= i_cache_output;
	pc_out <= pc_output;
	d_cache_out <= d_cache_output;
	alu_out <= alu_output;

	-- Now, we want to make the connections between the datapath.
	-- Handle all the MUXes, 5-bit instruction address, 16-bit immediate, number of bits changes

	-- 5-bit I_cache address
	i_cache_address <= pc_output(4 downto 0); -- the address is 5 bits

	-- 26-bit target address 
	target_address <= i_cache_output(25 downto 0);

	-- 5-bit rs instruction [25:21] for regFile
	read_a_rs_address <= i_cache_output(25 downto 21);

	-- 5-bit rt instruction [20:16] for regFile
	read_b_rt_address <= i_cache_output(20 downto 16);

	-- MUX for selecting rt [20:16] or rd [15:11] (5-bit) for regFile
	write_address_reg <= i_cache_output(20 downto 16) when reg_dst = '0' else
						i_cache_output(15 downto 11) when reg_dst = '1';
	
	-- Sign extend immediate input instruction [15:0]
	immediate_input <= i_cache_output(15 downto 0);

	-- MUX to select ALU y input
	y_in <= rt when alu_src = '0' else
			immediate_output when alu_src = '1';

	-- data cache address 5-bit
	 d_cache_address <= alu_output(4 downto 0); -- the address is 5 bits
	 
	 -- MUX to select d_in (32 bits) between d_cache_output and alu_out
	 d_in <= d_cache_output when reg_in_src = '0' else
			alu_output when reg_in_src = '1';


end arch_cpu_datapath;





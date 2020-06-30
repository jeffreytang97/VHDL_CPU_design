library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity next_address is
port( 
	rt, rs : in std_logic_vector(31 downto 0); -- two register inputs
	pc : in std_logic_vector(31 downto 0);
	target_address : in std_logic_vector(25 downto 0);
	branch_type : in std_logic_vector(1 downto 0);
	pc_sel : in std_logic_vector(1 downto 0);
	next_pc : out std_logic_vector(31 downto 0));

end next_address ;

architecture arch_next_address of next_address is

signal tempNextPC : std_logic_vector(31 downto 0);
signal sign_extend_vector : std_logic_vector(31 downto 0);

begin
	process(pc, pc_sel, tempNextPC, target_address, rt, rs, branch_type)
	begin
		if (pc_sel = "00") then

			if (branch_type = "00") then -- no branch
				tempNextPC <= pc + 1;

			elsif (branch_type = "01") then -- branch on equal
				if (rs = rt) then
					sign_extend_vector (31 downto 16) <= (others => target_address(15));
					sign_extend_vector (15 downto 0) <= target_address(15 downto 0);
					tempNextPC <= pc + sign_extend_vector + 1;
				else
					tempNextPC <= pc + 1;
				end if;

			elsif (branch_type = "10") then -- branch not equal
				if (rs /= rt) then
					sign_extend_vector (31 downto 16) <= (others => target_address(15));
					sign_extend_vector (15 downto 0) <= target_address(15 downto 0);
					tempNextPC <= pc + sign_extend_vector + 1;
				else
					tempNextPC <= pc + 1;
				end if;

			else -- branch less than zero
				if (signed(rs) < 0) then
					sign_extend_vector (31 downto 16) <= (others => target_address(15));
					sign_extend_vector (15 downto 0) <= target_address(15 downto 0);
					tempNextPC <= pc + sign_extend_vector + 1;
				else
					tempNextPC <= pc + 1;
				end if;
			end if;

		elsif (pc_sel = "01") then -- jump
			tempNextPC <= pc + ("000000" & target_address);

		elsif (pc_sel = "10") then -- jump register rs
			tempNextPC <= pc + rs;
			
		else -- pc_sel = "11", do nothing
			tempNextPC <= pc;

		end if;
	end process;

next_pc <= tempNextPC;

end arch_next_address;



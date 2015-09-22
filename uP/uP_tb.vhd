library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uP_tb is
end entity;

architecture a_uP_tb of uP_tb is

	component uP is
		port(	
		clock: in std_logic;
		reset: in std_logic;
		pc: out unsigned(15 downto 0);
		c_flag: out std_logic;
		z_flag: out std_logic;
		n_flag: out std_logic;
		lt_flag: out std_logic;
		r0: out unsigned(15 downto 0);
		r1: out unsigned(15 downto 0);
		r2: out unsigned(15 downto 0);
		r3: out unsigned(15 downto 0);
		r4: out unsigned(15 downto 0);
		r5: out unsigned(15 downto 0);
		r6: out unsigned(15 downto 0);
		r7: out unsigned(15 downto 0);
		state: out unsigned(1 downto 0);
		rom_output: out unsigned (14 downto 0);
		alu_output: out unsigned(15 downto 0);
		regbank_output_A: out unsigned(15 downto 0);
		regbank_output_B: out unsigned(15 downto 0)
		);
	end component;
	
	signal clock,reset: std_logic;
	signal r0,r1,r2,r3,r4,r5,r6,r7,pc: unsigned (15 downto 0);
	signal state: unsigned (1 downto 0);
	signal c_flag,z_flag,n_flag,lt_flag: std_logic;
	signal alu_out: unsigned (15 downto 0);
	signal operand_A, operand_B: unsigned (15 downto 0);
	signal rom_out: unsigned (14 downto 0);
	
begin
	
	test: uP port map(clock=>clock,reset=>reset,state=>state,r0=>r0,r1=>r1,r2=>r2,r3=>r3,r4=>r4,r5=>r5,r6=>r6,r7=>r7,pc=>pc,
							c_flag=>c_flag,z_flag=>z_flag,n_flag=>n_flag,lt_flag=>lt_flag,rom_output=>rom_out,alu_output=>alu_out,
							regbank_output_A=>operand_A,regbank_output_B=>operand_B);
	
	 	process -- sinal de clock
			begin
				clock <= '0';
            wait for 50 ns;
            clock <= '1';
            wait for 50 ns;
		end process;

       process
		  begin
			reset <= '1';
			wait for 100 ns;
			reset <= '0';
			wait;
       end process;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
	port(
		--inputs
		clk: in std_logic;
		rst: in std_logic;
		current_pc: in unsigned(15 downto 0);
		current_instruction: in unsigned(14 downto 0);
		c_flag: in std_logic;
		z_flag: in std_logic;
		n_flag: in std_logic;
		lt_flag: in std_logic;
		
		--outputs
		state: out unsigned(1 downto 0);
		wr_en_pc: out std_logic;
		wr_en_regbank: out std_logic;
		wr_en_ram: out std_logic;
		pc_address: out unsigned(15 downto 0);
		operand_A: out unsigned(2 downto 0);
		operand_B: out unsigned(2 downto 0);
		opcode: out unsigned(3 downto 0);
		immediate: out unsigned(15 downto 0);
		wr_data_source: out unsigned(3 downto 0);
		ccr_enable: out std_logic
	);
end entity;

architecture a_control of control is

component state_machine is
     port( 
         clk: in std_logic;
			rst: in std_logic;
         state: out unsigned(1 downto 0)  							--00=fetch, 01=decode, 10=execute
     );
end component;

signal state_sig: unsigned(1 downto 0);
signal jmp_address: unsigned(10 downto 0);
signal branch_offset: unsigned(15 downto 0);
signal opcode_sig: unsigned(3 downto 0);

begin
	control_state_machine: state_machine port map(clk=>clk,rst=>rst,state=>state_sig);

	opcode_sig <= current_instruction(14 downto 11);																				--retrieves opcode from current instruction
	jmp_address <= current_instruction(10 downto 0);																				--retrieves jmp address in case the instruction is a jmp
	
	branch_offset <= 	"11111" & current_instruction(10 downto 0) when current_instruction(10)='1' else				--retrieves branch offset in case the instruction is a branch
							"00000" & current_instruction(10 downto 0);																--performs sign extend as well (offset must be 15-bit wide)

	state <= state_sig;

	wr_en_regbank <= 	'1' when (state_sig="10" and (opcode_sig="0001" or opcode_sig="0010" or opcode_sig="0011" or opcode_sig="0100" or opcode_sig="1001" or (opcode_sig="1010" and current_instruction(10)='1'))) or (state_sig="00" and opcode_sig="1010" and current_instruction(10)='0') else		--enabled when instruction is supposed to write in the regbank 
							'0';
	
	operand_A <= current_instruction(7 downto 5) when state_sig="10" and opcode_sig="1001" else "111";				--when instruction is a mov, change operand_A to not be the default (accumulator)
	
	operand_B <= current_instruction(10 downto 8);			--makes operand_B deafult to reduce code
	
	opcode <= 	"0010" when opcode_sig="0101" else			--makes a sub operation at ALU if is a cmp instruction
					opcode_sig;											--real opcode otherwise
	
	wr_data_source <= 	"0010" when state_sig="10" and opcode_sig="1010" and current_instruction(10)='1' else		--immediate when lda #imm
								"0011" when state_sig="10" and opcode_sig="1001" else													--value in the source register on a mov instruction
								"0100" when state_sig="00" and opcode_sig="1010" and current_instruction(10)='0' else		--when loading from RAM
								"0001";																												--ALU output otherwise

	immediate <= 	"000000"&current_instruction(9 downto 0) 	when state_sig="10" and opcode_sig="1010" and current_instruction(9)='0' else		--sign extend if immediate is positive
						"111111"&current_instruction(9 downto 0) 	when state_sig="10" and opcode_sig="1010" and current_instruction(9)='1' else		--sign extend if immediate is negative
						"0000000000000000";																																			--zero otherwise

	wr_en_pc <= '1' when state_sig="01" else '0';

	pc_address <= 	"00000" & jmp_address 				when state_sig="01" and opcode_sig="1000" else
						current_pc + branch_offset			when state_sig="01" and (opcode_sig="0110" or (opcode_sig="0111" and z_flag='1') or (opcode_sig="1100" and lt_flag='1') or (opcode_sig="1101" and n_flag='1')) else
						current_pc + "0000000000000001" 	when state_sig="01" else
						current_pc;
						
	ccr_enable <= '1' when opcode_sig="0001" or opcode_sig="0010" or opcode_sig="0011" or opcode_sig="0100" or opcode_sig="0101" else '0';		--enables CCR if current instruction modifies any flags

	wr_en_ram <= '1' when state_sig="00" and opcode_sig="1011" else '0';		--Set if is a sta (store) instruction
	
end architecture;
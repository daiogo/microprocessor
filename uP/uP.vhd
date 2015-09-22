library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uP is
	port(
		--inputs
		clock: in std_logic;
		reset: in std_logic;
		
		--outputs
		pc: out unsigned(15 downto 0); 							--PC value
		c_flag: out std_logic;										--Carry flag
		z_flag: out std_logic;										--Zero flag
		n_flag: out std_logic;										--Negative flag
		lt_flag: out std_logic;										--Less Than flag
		r0: out unsigned(15 downto 0);							--Registers values
		r1: out unsigned(15 downto 0);
		r2: out unsigned(15 downto 0);
		r3: out unsigned(15 downto 0);
		r4: out unsigned(15 downto 0);
		r5: out unsigned(15 downto 0);
		r6: out unsigned(15 downto 0);
		r7: out unsigned(15 downto 0);
		
		--debug
		state: out unsigned(1 downto 0);	 						--Control unit state (fetch, decode, execute)
		rom_output: out unsigned (14 downto 0);				--ROM out content
		alu_output: out unsigned(15 downto 0);  				--ALU out content
		regbank_output_A: out unsigned(15 downto 0);			--Register bank outputs
		regbank_output_B: out unsigned(15 downto 0)
	);
end entity;

architecture a_uP of uP is
	
	component ram is
		port(
			clk: in std_logic;
			address: in unsigned(15 downto 0);
			wr_en: in std_logic;
			data_in: in unsigned(15 downto 0);
			data_out: out unsigned(15 downto 0)
		);
	end component;
	
	component condition_code_register is
		port( 
			clk: in std_logic;
			enable: in std_logic;
			c_D: in std_logic;
			z_D: in std_logic;
			n_D: in std_logic;
			lt_D: in std_logic;
			c_Q: out std_logic;
			z_Q: out std_logic;
			n_Q: out std_logic;
			lt_Q: out std_logic
		);
	end component;

	component mux4x1 is
		port(	
			in0: in unsigned(15 downto 0);
			in1: in unsigned(15 downto 0);
			in2: in unsigned(15 downto 0);
			in3: in unsigned(15 downto 0);
			sel: in unsigned(3 downto 0);
			out0: out unsigned(15 downto 0)
		);
	end component;
	
	component mux2x1 is
		port(
			in0: in unsigned(2 downto 0);
			in1: in unsigned(2 downto 0);
			sel: in unsigned(3 downto 0);
			out0: out unsigned(2 downto 0)
		);
	end component;
	
	component reg16bits is
		port(
			clk: in std_logic;
			rst: in std_logic;
			wr_en: in std_logic;
			data_in: in unsigned(15 downto 0);
			data_out: out unsigned(15 downto 0)
		);
	end component;
	
	component rom is
		port(
			clk: in std_logic;
			address: in unsigned(10 downto 0);
			data: out unsigned(14 downto 0)
		);
	end component;

	component register_bank is
		port(
			clock: in std_logic;
			reset: in std_logic;
			rd_register_A: in unsigned(2 downto 0);
			rd_register_B: in unsigned(2 downto 0);
			wr_data: in unsigned(15 downto 0);
			wr_register: in unsigned(2 downto 0);
			wr_enable: in std_logic;
			rd_data_A: out unsigned(15 downto 0);
			rd_data_B: out unsigned(15 downto 0);
			r0: out unsigned(15 downto 0);
			r1: out unsigned(15 downto 0);
			r2: out unsigned(15 downto 0);
			r3: out unsigned(15 downto 0);
			r4: out unsigned(15 downto 0);
			r5: out unsigned(15 downto 0);
			r6: out unsigned(15 downto 0);
			r7: out unsigned(15 downto 0)
		);
	end component;

	component alu is
		port(
			operand0: in unsigned(15 downto 0);
			operand1: in unsigned(15 downto 0);
			operation: in unsigned(3 downto 0);
			alu_out: out unsigned(15 downto 0);
			c_flag: out std_logic;
			z_flag: out std_logic;
			n_flag: out std_logic;
			lt_flag: out std_logic
		);
	end component;

	component control is
		port(
			clk: in std_logic;
			rst: in std_logic;
			current_pc: in unsigned(15 downto 0);
			current_instruction: in unsigned(14 downto 0);
			c_flag: in std_logic;
			z_flag: in std_logic;
			n_flag: in std_logic;
			lt_flag: in std_logic;
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
	end component;
	
--Connection signals
	signal state_sig: unsigned(1 downto 0);
	signal opcode_sig: unsigned(3 downto 0);
	signal operand_A_sig, operand_B_sig: unsigned(2 downto 0);
	signal operand_A_data_sig, operand_B_data_sig: unsigned(15 downto 0);
	signal alu_out_sig: unsigned(15 downto 0);
	signal wr_en_pc_sig: std_logic;
	signal wr_en_regbank_sig: std_logic;
	signal wr_en_ram_sig: std_logic;
	signal pc_out_sig, pc_in_sig: unsigned(15 downto 0);
	signal rom_out_sig: unsigned(14 downto 0);
	signal wr_data_sig, immediate_sig: unsigned(15 downto 0);
	signal wr_register_sig: unsigned(2 downto 0);
	signal c_flag_sig,z_flag_sig,n_flag_sig,lt_flag_sig: std_logic;
	signal control_c_flag_sig,control_z_flag_sig,control_n_flag_sig,control_lt_flag_sig: std_logic;
	signal ram_address_sig,ram_out_sig,accumulator_sig: unsigned(15 downto 0);
	signal write_data_source_sig: unsigned(3 downto 0);
	signal ccr_enable_sig: std_logic;

begin
	pc<=pc_out_sig;
	state<=state_sig;
	c_flag<=control_c_flag_sig;
	z_flag<=control_z_flag_sig;
	n_flag<=control_n_flag_sig;
	lt_flag<=control_lt_flag_sig;
	r6<=ram_address_sig;
	r7<=accumulator_sig;

	rom_output <= rom_out_sig;
	alu_output <= alu_out_sig;
	regbank_output_A <= operand_A_data_sig;
	regbank_output_B <= operand_B_data_sig;

	up_ram: ram port map(	clk=>clock,
									address=>ram_address_sig,
									wr_en=>wr_en_ram_sig,
									data_in=>accumulator_sig,
									data_out=>ram_out_sig
	);

	up_ccr: condition_code_register port map(	clk=>clock,
															enable=>ccr_enable_sig,
															c_D=>c_flag_sig,
															z_D=>z_flag_sig,
															n_D=>n_flag_sig,
															lt_D=>lt_flag_sig,
															c_Q=>control_c_flag_sig,
															z_Q=>control_z_flag_sig,
															n_Q=>control_n_flag_sig,
															lt_Q=>control_lt_flag_sig
	);

	up_control: control port map(	clk=>clock,
											rst=>reset,
											state=>state_sig,
											wr_en_pc=>wr_en_pc_sig,
											wr_en_regbank=>wr_en_regbank_sig,
											current_instruction=>rom_out_sig,
											pc_address=>pc_in_sig,
											current_pc=>pc_out_sig,
											operand_A=>operand_A_sig,
											operand_B=>operand_B_sig,
											opcode=>opcode_sig,
											immediate=>immediate_sig,
											wr_data_source=>write_data_source_sig,
											c_flag=>control_c_flag_sig,
											z_flag=>control_z_flag_sig,
											n_flag=>control_n_flag_sig,
											lt_flag=>control_lt_flag_sig,
											ccr_enable=>ccr_enable_sig,
											wr_en_ram=>wr_en_ram_sig
	);
	
	up_alu: alu port map(	operand0=>operand_A_data_sig,
									operand1=>operand_B_data_sig,
									operation=>opcode_sig,
									alu_out=>alu_out_sig,
									c_flag=>c_flag_sig,
									z_flag=>z_flag_sig,
									n_flag=>n_flag_sig,
									lt_flag=>lt_flag_sig
	);
	
	up_rom: rom port map(	clk=>clock,
									address=>pc_out_sig(10 downto 0),
									data=>rom_out_sig
	);
	
	up_regbank: register_bank port map(	clock=>clock,
													reset=>reset,
													rd_register_A=>operand_A_sig,
													rd_register_B=>operand_B_sig,
													wr_data=>wr_data_sig,
													wr_register=>wr_register_sig,
													wr_enable=>wr_en_regbank_sig,
													rd_data_A=>operand_A_data_sig,
													rd_data_B=>operand_B_data_sig,
													r0=>r0,r1=>r1,r2=>r2,
													r3=>r3,r4=>r4,r5=>r5,
													r6=>ram_address_sig,
													r7=>accumulator_sig
	);
	
	up_pc: reg16bits port map(	clk=>clock,
										rst=>reset,
										wr_en=>wr_en_pc_sig,
										data_in=>pc_in_sig,
										data_out=>pc_out_sig
	);
	
	up_wr_data_mux: mux4x1 port map(	in0=>alu_out_sig,
												in1=>immediate_sig,
												in2=>operand_B_data_sig,
												in3=>ram_out_sig,
												sel=>write_data_source_sig,
												out0=>wr_data_sig
	);
	
	up_wr_register_mux: mux2x1 port map(in0=>"111",
													in1=>operand_A_sig,
													sel=>write_data_source_sig,
													out0=>wr_register_sig
	);
	
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port(	
		operand0: in unsigned(15 downto 0);
		operand1: in unsigned(15 downto 0);
		operation: in unsigned(3 downto 0);
		alu_out: out unsigned(15 downto 0);
		c_flag: out std_logic;						--carry flag
		z_flag: out std_logic;						--zero flag
		n_flag: out std_logic;						--negative flag
		lt_flag: out std_logic						--overflow flag
	);
end entity;

architecture a_alu of alu is
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
	
	component arithmetic_circuit is
		port(	
			a: in unsigned(15 downto 0);
			b: in unsigned(15 downto 0);
			sum: out unsigned(15 downto 0);
			sub: out unsigned(15 downto 0);
			slt: out unsigned(15 downto 0);
			sneg: out unsigned(15 downto 0)
		);
	end component;
	
	signal sum_sig, sub_sig, slt_sig, sneg_sig: unsigned(15 downto 0);
	signal A_17bits_sig, B_17bits_sig,sum_17bits_sig: unsigned(16 downto 0);
	signal alu_out_sig: unsigned(15 downto 0);
	
begin
	A_17bits_sig <= 	"0"&operand0 when operand0(15)='0' else
							"1"&operand0 when operand0(15)='1';
	B_17bits_sig <= 	"0"&operand1 when operand1(15)='0' else
							"1"&operand1 when operand1(15)='1';

	sum_17bits_sig <= A_17bits_sig + B_17bits_sig;

	c_flag <= 	sum_17bits_sig(16) when operation="0001" else 
					'1' when operation="0010" and operand1 <= operand0 else
					'0';
	z_flag <= '1' when alu_out_sig="0000000000000000" else '0';
	n_flag <= '1' when alu_out_sig(15)='1' else '0';
	lt_flag <= '1' when slt_sig="0000000000000001" else '0';
	
	alu_out <= alu_out_sig;
	
	alu_mux: mux4x1 port map(in0=>sum_sig,in1=>sub_sig,in2=>slt_sig,in3=>sneg_sig,sel=>operation,out0=>alu_out_sig);
	alu_arithmetic_circuit: arithmetic_circuit port map(a=>operand0,b=>operand1,sum=>sum_sig,sub=>sub_sig,slt=>slt_sig,sneg=>sneg_sig);
end architecture;

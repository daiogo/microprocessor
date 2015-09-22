library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_bank is
	port(
		--inputs
		clock: in std_logic;
		reset: in std_logic;
		rd_register_A: in unsigned(2 downto 0);			--operand register 0
		rd_register_B: in unsigned(2 downto 0);			--operand register 1
		wr_data: in unsigned(15 downto 0);					--value to be written at destination register
		wr_register: in unsigned(2 downto 0);				--destination register to be written in
		wr_enable: in std_logic;								--write enable
		
		--outputs
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
end entity;

architecture a_register_bank of register_bank is
	component mux8x2 is
		port(	
			in0: in unsigned(15 downto 0);
			in1: in unsigned(15 downto 0);
			in2: in unsigned(15 downto 0);
			in3: in unsigned(15 downto 0);
			in4: in unsigned(15 downto 0);
			in5: in unsigned(15 downto 0);
			in6: in unsigned(15 downto 0);
			in7: in unsigned(15 downto 0);
			sel0: in unsigned(2 downto 0);
			sel1: in unsigned(2 downto 0);
			out0: out unsigned(15 downto 0);
			out1: out unsigned(15 downto 0)
		);
	end component;

	component demux1x8 is
		port(	
			in_demux: in std_logic;
			sel: in unsigned(2 downto 0);
			out0: out std_logic;
			out1: out std_logic;
			out2: out std_logic;
			out3: out std_logic;
			out4: out std_logic;
			out5: out std_logic;
			out6: out std_logic;
			out7: out std_logic
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

	signal reg0_sig,reg1_sig,reg2_sig,reg3_sig,reg4_sig,reg5_sig,reg6_sig,reg7_sig: unsigned(15 downto 0);
	signal wr_en0_sig,wr_en1_sig,wr_en2_sig,wr_en3_sig,wr_en4_sig,wr_en5_sig,wr_en6_sig,wr_en7_sig: std_logic;

	begin
		r0<=reg0_sig;
		r1<=reg1_sig;
		r2<=reg2_sig;
		r3<=reg3_sig;
		r4<=reg4_sig;
		r5<=reg5_sig;
		r6<=reg6_sig;
		r7<=reg7_sig;
		
		regbank_mux: mux8x2 port map(	in0=>reg0_sig,in1=>reg1_sig,in2=>reg2_sig,in3=>reg3_sig,in4=>reg4_sig,
												in5=>reg5_sig,in6=>reg6_sig,in7=>reg7_sig,sel0=>rd_register_A,sel1=>rd_register_B,
												out0=>rd_data_A,out1=>rd_data_B);
		
		regbank_demux: demux1x8 port map(in_demux=>wr_enable,sel=>wr_register,out0=>wr_en0_sig,out1=>wr_en1_sig,
													out2=>wr_en2_sig,out3=>wr_en3_sig,out4=>wr_en4_sig,out5=>wr_en5_sig,
													out6=>wr_en6_sig,out7=>wr_en7_sig);
		
		register0: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en0_sig,data_in=>wr_data,data_out=>reg0_sig);
		register1: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en1_sig,data_in=>wr_data,data_out=>reg1_sig);
		register2: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en2_sig,data_in=>wr_data,data_out=>reg2_sig);
		register3: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en3_sig,data_in=>wr_data,data_out=>reg3_sig);
		register4: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en4_sig,data_in=>wr_data,data_out=>reg4_sig);
		register5: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en5_sig,data_in=>wr_data,data_out=>reg5_sig);
		register6: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en6_sig,data_in=>wr_data,data_out=>reg6_sig);
		register7: reg16bits port map(clk=>clock,rst=>reset,wr_en=>wr_en7_sig,data_in=>wr_data,data_out=>reg7_sig);
end architecture;

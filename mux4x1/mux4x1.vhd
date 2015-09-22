library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4x1 is
	port(	
		in0: in unsigned(15 downto 0);
		in1: in unsigned(15 downto 0);
		in2: in unsigned(15 downto 0);
		in3: in unsigned(15 downto 0);
		sel: in unsigned(3 downto 0);
		out0: out unsigned(15 downto 0)
	);
end entity;

-- ***OPCODES***
--	 sum = 0001
--	 sub = 0010
--	 slt = 0011
--	sneg = 0100

architecture a_mux4x1 of mux4x1 is
begin
	out0 <=	in0 when sel="0001" else	--sum
				in1 when sel="0010" else	--sub
				in2 when sel="0011" else	--slt
				in3 when sel="0100" else	--sneg
				"----------------";
end architecture;

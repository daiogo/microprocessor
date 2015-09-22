library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2x1 is
	port(	
		in0: in unsigned(2 downto 0);
		in1: in unsigned(2 downto 0);
		sel: in unsigned(3 downto 0);
		out0: out unsigned(2 downto 0)
	);
end entity;

architecture a_mux2x1 of mux2x1 is
begin
	out0 <=	in1 when sel="0011" else in0;
end architecture;

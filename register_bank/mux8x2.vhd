library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux8x2 is
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
end entity;

architecture a_mux8x2 of mux8x2 is
begin
	out0 <=	in0 when sel0="000" else
				in1 when sel0="001" else
				in2 when sel0="010" else
				in3 when sel0="011" else
				in4 when sel0="100" else
				in5 when sel0="101" else
				in6 when sel0="110" else
				in7 when sel0="111" else
				"----------------";
				
	out1 <=	in0 when sel1="000" else
				in1 when sel1="001" else
				in2 when sel1="010" else
				in3 when sel1="011" else
				in4 when sel1="100" else
				in5 when sel1="101" else
				in6 when sel1="110" else
				in7 when sel1="111" else
				"----------------";
end architecture;

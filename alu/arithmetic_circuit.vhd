library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arithmetic_circuit is
	port(	
		a: in unsigned(15 downto 0);				--operand 0
		b: in unsigned(15 downto 0);				--operand 1
		sum: out unsigned(15 downto 0);			--sum: a+b
		sub: out unsigned(15 downto 0);			--sub: a-b
		slt: out unsigned(15 downto 0);			--slt: set if A less than B
		sneg: out unsigned(15 downto 0)			--sneg: set if A is negative
	);
end entity;

architecture a_arithmetic_circuit of arithmetic_circuit is
begin
	sum <= a+b;
	sub <= a-b;
	slt <=	--works only for positive numbers comparison
				"0000000000000001" when a(15)='0' and b(15)='0' and a<b else
				"0000000000000000" when a(15)='0' and b(15)='0' and a>=b else
				
				--negative numbers comparison 
				"0000000000000001" when a(15)='1' and b(15)='0' else														--Ex: -2 < 1 
				"0000000000000001" when a(15)='1' and b(15)='1' and a(14 downto 0) < b(14 downto 0) else		--Ex: -2 <-1 
				"0000000000000000" when a(15)='1' and b(15)='1' and a(14 downto 0) >= b(14 downto 0) else 	--Ex: -1 >-2 or -1=-1
				
				"----------------";
	sneg <= (15 downto 1 => '0')&a(15);			--concatenate zeros from 15 to 1 with A's MSB
end architecture;
